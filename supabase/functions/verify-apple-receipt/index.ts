/// <reference lib="deno.ns" />
/// <reference lib="dom" />
// Supabase Edge Function: verify-apple-receipt
// Enhanced Apple App Store receipt validation with production-ready features
// Validates receipts, handles subscription status, and provides detailed error reporting
//
// S2: this function now ALSO performs the user_subscriptions write, using
// service role, keyed off the product_id Apple itself confirms in the
// receipt - never the client-supplied planId. Previously the client called
// this purely to check `valid: true` and then inserted the subscription row
// itself with whatever plan/tier/amount it chose, so a user could submit a
// receipt for a cheap product and client-insert an expensive tier, or skip
// calling this function entirely and just POST directly to
// /rest/v1/user_subscriptions (that path is now blocked by a DB trigger -
// see guard_subscription_booking_inserts).
//
// S3 (2026-08-15): the client's in_app_purchase_storekit plugin (^0.4.8+1)
// uses StoreKit 2 on iOS 15+, so PurchaseDetails.verificationData.
// serverVerificationData is a signed JWS transaction (header.payload.
// signature, dot-separated), NOT the legacy whole-app base64 PKCS#7 receipt
// blob the old /verifyReceipt flow expects. Every purchase was hitting
// "Invalid receipt data format. Must be base64 encoded." - not a sandbox
// flakiness issue, a hard format mismatch that blocked 100% of purchases.
// This now detects JWS input and verifies it locally: validates the x5c
// certificate chain in the JWS header terminates at a pinned genuine Apple
// Root CA - G3 certificate (downloaded directly from
// https://www.apple.com/certificateauthority/AppleRootCA-G3.cer, sha256
// fingerprint 63:34:3A:BF:B8:9A:6A:03:EB:B5:7E:9B:3F:5F:A7:BE:7C:4F:5C:75:
// 6F:30:17:B3:A8:C4:88:C3:65:3E:91:79), then verifies the JWS signature
// against the leaf certificate's public key. This is the same trust model
// Apple's own server libraries use, just implemented directly since Apple
// doesn't publish an official Deno library. The legacy /verifyReceipt path
// is kept as a fallback for any old app version still submitting whole
// receipts.

import 'npm:reflect-metadata';
import { createClient } from 'npm:@supabase/supabase-js@2'
import { importX509, compactVerify } from 'npm:jose@5'
import { X509Certificate, BasicConstraintsExtension } from 'npm:@peculiar/x509@1'

type VerifyRequest = {
  userId: string;
  planId?: string; // client hint only, never trusted for the DB write
  transactionId?: string; // optional: omitted for restore/resync calls
  receiptData: string; // base64 legacy receipt, OR a JWS compact string (StoreKit 2)
};

type AppleVerifyResponse = {
  status: number;
  environment?: string;
  receipt?: Record<string, unknown>;
  latest_receipt?: string;
  latest_receipt_info?: Array<Record<string, unknown>>;
  pending_renewal_info?: Array<Record<string, unknown>>;
};

type EnhancedResponse = {
  valid: boolean;
  environment?: string;
  status: number;
  matchedTransaction: boolean;
  productId: string | null;
  transactionId: string | null;
  originalTransactionId: string | null;
  expiresDateMs: string | null;
  isExpired?: boolean;
  subscriptionStatus?: 'active' | 'expired' | 'cancelled' | 'pending';
  autoRenewStatus?: boolean;
  planId: string | null;
  userId: string;
  subscription?: Record<string, unknown> | null;
  error?: string;
  timestamp: string;
};

// Common shape both the JWS path and the legacy /verifyReceipt path
// normalize into, so the DB-write logic below only has to be written once.
type NormalizedVerification = {
  valid: boolean;
  environment: string;
  appleStatus: number;
  matched: boolean;
  appleProductId: string | null;
  appleTransactionId: string | null;
  originalTransactionId: string | null;
  expiresDateMs: string | null;
  isExpired: boolean;
  subscriptionStatus: 'active' | 'expired' | 'cancelled' | 'pending';
  autoRenewStatus: boolean;
};

// Apple product ID -> internal plan ID / tier. Must match App Store Connect
// config and subscription_plans.id (mirrors the client's now-unused mapping
// in subscription_service.dart - kept here because this is the trust boundary).
const APPLE_PRODUCT_TO_PLAN_ID: Record<string, string> = {
  '3SUB': 'quarterly_plan',
  '1month': 'monthly_plan',
  '7day': 'weekly_plan',
  '365day': 'annual_plan',
};
const APPLE_PRODUCT_TO_TIER: Record<string, string> = {
  '7day': 'Gold',
  '1month': 'Platinum',
  '3SUB': 'Platinum',
  '365day': 'Black',
};

const APPLE_PRODUCTION_URL = "https://buy.itunes.apple.com/verifyReceipt";
const APPLE_SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt";

// App's iOS bundle ID - defense in depth, reject a validly-signed JWS
// transaction that belongs to some other app.
const EXPECTED_BUNDLE_ID = 'com.a.aPlayWorld';

// Apple-specific certificate policy OIDs, present on genuine Apple-issued
// StoreKit certificates (leaf = In-App Purchase signing cert, intermediate
// = WWDR CA). Checking these - not just the signature chain - mirrors
// Apple's own official app-store-server-library reference implementation
// (github.com/apple/app-store-server-library-node, jws_verification.ts)
// exactly, so a chain that merely chains to our pinned root but was issued
// for some unrelated purpose is still rejected.
const APPLE_LEAF_POLICY_OID = '1.2.840.113635.100.6.11.1';
const APPLE_INTERMEDIATE_POLICY_OID = '1.2.840.113635.100.6.2.1';

// Apple Root CA - G3, DER bytes (standard base64), fetched directly from
// https://www.apple.com/certificateauthority/AppleRootCA-G3.cer on
// 2026-08-15. sha256 fingerprint: 63:34:3A:BF:B8:9A:6A:03:EB:B5:7E:9B:3F:5F:
// A7:BE:7C:4F:5C:75:6F:30:17:B3:A8:C4:88:C3:65:3E:91:79. StoreKit 2 JWS
// transactions are signed by a chain that must terminate at this exact
// certificate - pinning it (rather than trusting whatever root the client
// sends) is what stops a forged receipt from being accepted.
const APPLE_ROOT_CA_G3_B64 =
  "MIICQzCCAcmgAwIBAgIILcX8iNLFS5UwCgYIKoZIzj0EAwMwZzEbMBkGA1UEAwwS" +
  "QXBwbGUgUm9vdCBDQSAtIEczMSYwJAYDVQQLDB1BcHBsZSBDZXJ0aWZpY2F0aW9u" +
  "IEF1dGhvcml0eTETMBEGA1UECgwKQXBwbGUgSW5jLjELMAkGA1UEBhMCVVMwHhcN" +
  "MTQwNDMwMTgxOTA2WhcNMzkwNDMwMTgxOTA2WjBnMRswGQYDVQQDDBJBcHBsZSBS" +
  "b290IENBIC0gRzMxJjAkBgNVBAsMHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9y" +
  "aXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzB2MBAGByqGSM49" +
  "AgEGBSuBBAAiA2IABJjpLz1AcqTtkyJygRMc3RCV8cWjTnHcFBbZDuWmBSp3ZHtf" +
  "TjjTuxxEtX/1H7YyYl3J6YRbTzBPEVoA/VhYDKX1DyxNB0cTddqXl5dvMVztK517" +
  "IDvYuVTZXpmkOlEKMaNCMEAwHQYDVR0OBBYEFLuw3qFYM4iapIqZ3r6966/ayySr" +
  "MA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMAoGCCqGSM49BAMDA2gA" +
  "MGUCMQCD6cHEFl4aXTQY2e3v9GwOAEZLuN+yRhHFD/3meoyhpmvOwgPUnPWTxnS4" +
  "at+qIxUCMG1mihDK1A3UT82NQz60imOlM27jbdoXt2QfyFMm+YhidDkLF1vLUagM" +
  "6BgD56KyKA==";

// Apple status codes mapping
const APPLE_STATUS_CODES: Record<number, string> = {
  0: "Valid receipt",
  21000: "The App Store could not read the JSON object you provided",
  21002: "The data in the receipt-data property was malformed or missing",
  21003: "The receipt could not be authenticated",
  21004: "The shared secret you provided does not match the shared secret on file",
  21005: "The receipt server is not currently available",
  21006: "This receipt is valid but the subscription has expired",
  21007: "This receipt is from the sandbox environment",
  21008: "This receipt is from the production environment",
  21010: "This receipt could not be authorized"
};

const jsonHeaders = {
  "content-type": "application/json",
  "cache-control": "no-store",
};

// Persist a row to iap_events for every verification attempt (success or
// failure). console.log/error in Deno edge functions only lives in Supabase's
// short log retention and isn't queryable by user - this is the durable trail
// that lets a specific user's failed purchase be diagnosed after the fact.
// Never let a logging failure affect the actual verification response.
async function logIapEvent(
  admin: ReturnType<typeof createClient>,
  params: {
    userId?: string | null;
    event: string;
    level?: 'info' | 'warn' | 'error';
    productId?: string | null;
    transactionId?: string | null;
    message?: string;
    detail?: Record<string, unknown>;
  },
): Promise<void> {
  try {
    await admin.from('iap_events').insert({
      user_id: params.userId ?? null,
      source: 'server',
      event: params.event,
      level: params.level ?? 'info',
      product_id: params.productId ?? null,
      transaction_id: params.transactionId ?? null,
      platform: 'ios',
      message: params.message ?? null,
      detail: params.detail ?? null,
    });
  } catch (e) {
    console.error(`Failed to write iap_events row: ${e instanceof Error ? e.message : String(e)}`);
  }
}

function errorResponse(message: string, status = 400): Response {
  console.error(`Apple Receipt Validation Error: ${message}`);
  return new Response(JSON.stringify({
    valid: false,
    error: message,
    timestamp: new Date().toISOString()
  }), {
    headers: jsonHeaders,
    status,
  });
}

// ============================== StoreKit 2 JWS path ==============================

type JWSTransactionPayload = {
  transactionId: string;
  originalTransactionId: string;
  bundleId: string;
  productId: string;
  purchaseDate: number;
  originalPurchaseDate?: number;
  expiresDate?: number;
  type: string;
  inAppOwnershipType?: string;
  signedDate: number;
  environment: 'Sandbox' | 'Production';
  revocationDate?: number;
  revocationReason?: number;
};

function certFromStdB64(b64: string): X509Certificate {
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return new X509Certificate(bytes);
}

function base64UrlDecodeToString(segment: string): string {
  const b64 = segment.replace(/-/g, '+').replace(/_/g, '/');
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return new TextDecoder().decode(bytes);
}

// x5c (per RFC 7515) is leaf-first, standard (not url-safe) base64 DER
// certs. Apple always sends exactly 3: [leaf, intermediate, root]. Mirrors
// apple/app-store-server-library-node's verifyCertificateChainWithoutCaching
// precisely: only certs [0] and [1] are used cryptographically (the 3rd,
// root, entry in x5c is not trusted - our own pinned root is used instead);
// intermediate must chain to our pinned root by signature AND issuer/subject
// string match, intermediate must carry the CA basic-constraint, leaf and
// intermediate must carry Apple's own StoreKit/WWDR policy OIDs, and every
// cert in the chain must be within its validity window right now. Returns
// the leaf cert for JWS signature verification.
async function verifyAppleCertChain(x5c: string[]): Promise<X509Certificate> {
  if (!x5c || x5c.length !== 3) {
    throw new Error(`x5c must contain exactly 3 certificates, got ${x5c?.length ?? 0}`);
  }
  const [leaf, intermediate] = x5c.slice(0, 2).map(certFromStdB64);
  const pinnedRoot = certFromStdB64(APPLE_ROOT_CA_G3_B64);

  const intermediateSignedByRoot = await intermediate.verify({ publicKey: pinnedRoot.publicKey });
  if (!intermediateSignedByRoot || intermediate.issuer !== pinnedRoot.subject) {
    throw new Error('Intermediate certificate is not signed by the pinned Apple Root CA - G3');
  }

  const leafSignedByIntermediate = await leaf.verify({ publicKey: intermediate.publicKey });
  if (!leafSignedByIntermediate || leaf.issuer !== intermediate.subject) {
    throw new Error('Leaf certificate is not signed by the intermediate certificate');
  }

  const basicConstraints = intermediate.getExtension(BasicConstraintsExtension);
  if (!basicConstraints?.ca) {
    throw new Error('Intermediate certificate is not a valid CA certificate');
  }

  if (!leaf.getExtension(APPLE_LEAF_POLICY_OID)) {
    throw new Error('Leaf certificate is missing the Apple In-App Purchase policy extension');
  }
  if (!intermediate.getExtension(APPLE_INTERMEDIATE_POLICY_OID)) {
    throw new Error('Intermediate certificate is missing the Apple WWDR policy extension');
  }

  const now = new Date();
  for (const cert of [leaf, intermediate, pinnedRoot]) {
    if (now < cert.notBefore || now > cert.notAfter) {
      throw new Error('A certificate in the chain is outside its validity period');
    }
  }

  return leaf;
}

async function verifyAndDecodeJWSTransaction(jws: string): Promise<JWSTransactionPayload> {
  const parts = jws.split('.');
  if (parts.length !== 3) {
    throw new Error('Not a valid JWS compact serialization');
  }

  const headerJson = JSON.parse(base64UrlDecodeToString(parts[0])) as { alg?: string; x5c?: string[] };
  const x5c = headerJson.x5c;
  if (!x5c || x5c.length === 0) {
    throw new Error('JWS header missing x5c certificate chain');
  }

  await verifyAppleCertChain(x5c);

  const leafPem = `-----BEGIN CERTIFICATE-----\n${(x5c[0].match(/.{1,64}/g) ?? [x5c[0]]).join('\n')}\n-----END CERTIFICATE-----`;
  const publicKey = await importX509(leafPem, headerJson.alg ?? 'ES256');

  const { payload } = await compactVerify(jws, publicKey);
  const decoded = JSON.parse(new TextDecoder().decode(payload)) as JWSTransactionPayload;

  if (decoded.bundleId !== EXPECTED_BUNDLE_ID) {
    throw new Error(`Transaction bundleId "${decoded.bundleId}" does not match app bundleId "${EXPECTED_BUNDLE_ID}"`);
  }

  return decoded;
}

function normalizeFromJWS(payload: JWSTransactionPayload): NormalizedVerification {
  const now = Date.now();
  const isRevoked = payload.revocationDate != null;
  const isExpired = isRevoked ? true : (payload.expiresDate ? payload.expiresDate < now : false);
  const subscriptionStatus: NormalizedVerification['subscriptionStatus'] = isRevoked
    ? 'cancelled'
    : isExpired
      ? 'expired'
      : 'active';

  return {
    valid: !isRevoked,
    environment: payload.environment,
    appleStatus: 0,
    matched: true,
    appleProductId: payload.productId,
    appleTransactionId: payload.transactionId,
    originalTransactionId: payload.originalTransactionId ?? payload.transactionId,
    expiresDateMs: payload.expiresDate != null ? String(payload.expiresDate) : null,
    isExpired,
    subscriptionStatus,
    // No separate renewal-info JWS is sent by the client for a single
    // purchase confirmation, so this is a best-effort default (true unless
    // we already know the transaction is expired/revoked) - informational
    // only, does not gate access.
    autoRenewStatus: !isExpired && !isRevoked,
  };
}

// ============================== Legacy /verifyReceipt path ==============================

async function verifyWithApple(
  url: string,
  receiptData: string,
  sharedSecret: string,
): Promise<AppleVerifyResponse> {
  const body = {
    "receipt-data": receiptData,
    password: sharedSecret,
    "exclude-old-transactions": true,
  };

  console.log(`Verifying receipt with Apple: ${url.includes('sandbox') ? 'Sandbox' : 'Production'}`);

  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    throw new Error(`Apple verifyReceipt HTTP ${res.status}: ${res.statusText}`);
  }

  const data = (await res.json()) as AppleVerifyResponse;
  console.log(`Apple response status: ${data.status} - ${APPLE_STATUS_CODES[data.status] || 'Unknown status'}`);

  return data;
}

function findMatchingInfo(
  apple: AppleVerifyResponse,
  transactionId?: string,
  productId?: string,
) {
  const infos = apple.latest_receipt_info ?? [];

  if (transactionId) {
    const match = infos.find((i) => i?.transaction_id === transactionId);
    if (match) {
      console.log(`Found matching transaction: ${transactionId}`);
      return { match, matched: true };
    }
    console.log(`Transaction ${transactionId} not found, falling back`);
  }

  // Restore/resync calls know the product but not a specific transaction -
  // pick that product's most recent (highest expiry) entry.
  if (productId) {
    const productMatches = infos.filter((i) => i?.product_id === productId);
    if (productMatches.length > 0) {
      const latestForProduct = productMatches.sort(
        (a, b) => parseInt(String(b.expires_date_ms ?? '0')) - parseInt(String(a.expires_date_ms ?? '0')),
      )[0];
      return { match: latestForProduct, matched: false };
    }
  }

  const latest = infos.length > 0 ? infos[infos.length - 1] : undefined;
  return { match: latest, matched: false };
}

function determineSubscriptionStatus(
  match: Record<string, unknown> | undefined,
  pendingRenewalInfo?: Array<Record<string, unknown>>
): { isExpired: boolean; subscriptionStatus: 'active' | 'expired' | 'cancelled' | 'pending'; autoRenewStatus: boolean } {
  if (!match) {
    return { isExpired: true, subscriptionStatus: 'expired', autoRenewStatus: false };
  }

  const expiresDateMs = match.expires_date_ms as string;
  const now = Date.now();
  const isExpired = expiresDateMs ? parseInt(expiresDateMs) < now : false;

  // Check pending renewal info for auto-renew status
  const renewalInfo = pendingRenewalInfo?.[0];
  const autoRenewStatus = renewalInfo?.auto_renew_status === "1";

  let subscriptionStatus: 'active' | 'expired' | 'cancelled' | 'pending' = 'active';

  if (isExpired) {
    if (autoRenewStatus) {
      subscriptionStatus = 'pending'; // Expired but will renew
    } else {
      subscriptionStatus = renewalInfo?.expiration_intent ? 'cancelled' : 'expired';
    }
  }

  return { isExpired, subscriptionStatus, autoRenewStatus };
}

async function verifyLegacyReceipt(
  receiptData: string,
  transactionId: string | undefined,
  planIdHint: string | undefined,
  sharedSecret: string,
): Promise<NormalizedVerification> {
  let apple = await verifyWithApple(APPLE_PRODUCTION_URL, receiptData, sharedSecret);
  let environment = "Production";

  // If this is a sandbox receipt in production, switch to sandbox per Apple docs
  if (apple.status === 21007) {
    console.log("Sandbox receipt detected, switching to sandbox environment");
    apple = await verifyWithApple(APPLE_SANDBOX_URL, receiptData, sharedSecret);
    environment = "Sandbox";
  }

  if (apple.status !== 0 && apple.status !== 21006) {
    const errorMessage = APPLE_STATUS_CODES[apple.status] || `Unknown Apple status: ${apple.status}`;
    throw Object.assign(new Error(errorMessage), { appleStatus: apple.status, environment });
  }

  const clientProductHint = planIdHint
    ? Object.entries(APPLE_PRODUCT_TO_PLAN_ID).find(([, v]) => v === planIdHint)?.[0]
    : undefined;
  const { match, matched } = findMatchingInfo(apple, transactionId, clientProductHint);
  const valid = apple.status === 0 || apple.status === 21006; // 21006 means valid but expired

  const { isExpired, subscriptionStatus, autoRenewStatus } = determineSubscriptionStatus(
    match,
    apple.pending_renewal_info
  );

  return {
    valid,
    environment: apple.environment ?? environment,
    appleStatus: apple.status,
    matched,
    appleProductId: match?.product_id as string | undefined ?? null,
    appleTransactionId: match?.transaction_id as string | undefined ?? null,
    originalTransactionId: match?.original_transaction_id as string | undefined ?? null,
    expiresDateMs: match?.expires_date_ms as string ?? null,
    isExpired,
    subscriptionStatus,
    autoRenewStatus,
  };
}

// ============================== Handler ==============================

Deno.serve(async (req: Request) => {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin = createClient(supabaseUrl, serviceRoleKey);
  let payload: Partial<VerifyRequest> = {};

  try {
    if (req.method !== "POST") {
      return errorResponse("Method not allowed", 405);
    }

    payload = (await req.json()) as Partial<VerifyRequest>;
    const { userId, transactionId, receiptData } = payload;

    if (!userId || !receiptData) {
      await logIapEvent(admin, {
        userId,
        event: 'verify_bad_request',
        level: 'error',
        transactionId,
        message: 'Missing required fields: userId, receiptData',
      });
      return errorResponse("Missing required fields: userId, receiptData");
    }

    // Identify the caller from their JWT and require it to match the
    // userId the subscription would be written to - otherwise anyone could
    // activate a subscription for an arbitrary victim account.
    const authHeader = req.headers.get('Authorization') ?? '';
    const jwt = authHeader.replace(/^Bearer\s+/i, '');

    if (!jwt) {
      await logIapEvent(admin, {
        userId, event: 'verify_auth_error', level: 'error', transactionId,
        message: 'Missing Authorization header',
      });
      return errorResponse('Missing Authorization header', 401);
    }
    const { data: callerData, error: callerError } = await admin.auth.getUser(jwt);
    if (callerError || !callerData?.user || callerData.user.id !== userId) {
      await logIapEvent(admin, {
        userId, event: 'verify_auth_error', level: 'error', transactionId,
        message: 'Caller does not match userId',
        detail: { callerError: callerError?.message, callerId: callerData?.user?.id },
      });
      return errorResponse('Caller does not match userId', 403);
    }

    console.log(`Processing receipt verification for user: ${userId}, transaction: ${transactionId ?? '(latest)'}`);
    await logIapEvent(admin, {
      userId, event: 'verify_request', transactionId,
      productId: payload.planId,
      message: 'Receipt verification request received',
    });

    const isJWS = receiptData.split('.').length === 3;
    let normalized: NormalizedVerification;

    if (isJWS) {
      try {
        const decoded = await verifyAndDecodeJWSTransaction(receiptData);
        normalized = normalizeFromJWS(decoded);
        await logIapEvent(admin, {
          userId, event: 'verify_jws_decoded', transactionId: decoded.transactionId,
          productId: decoded.productId,
          message: `environment=${decoded.environment} revoked=${decoded.revocationDate != null}`,
        });
      } catch (e) {
        const message = e instanceof Error ? e.message : String(e);
        await logIapEvent(admin, {
          userId, event: 'verify_jws_invalid', level: 'error', transactionId,
          message,
        });
        return errorResponse(`Invalid StoreKit transaction: ${message}`, 422);
      }
    } else {
      const sharedSecret =
        Deno.env.get("APPLE_SHARED_SECRET") || Deno.env.get("IOS_SHARED_SECRET") || "";
      if (!sharedSecret) {
        await logIapEvent(admin, {
          event: 'verify_config_error',
          level: 'error',
          message: 'APPLE_SHARED_SECRET not configured on the edge function',
        });
        return errorResponse(
          "Missing APPLE_SHARED_SECRET. Set with `supabase secrets set APPLE_SHARED_SECRET=...`",
          500,
        );
      }

      try {
        atob(receiptData); // Test if it's valid base64
      } catch {
        await logIapEvent(admin, {
          userId, event: 'verify_bad_request', level: 'error', transactionId,
          message: 'Invalid receipt data format (not base64, not a 3-part JWS)',
        });
        return errorResponse("Invalid receipt data format. Must be base64 encoded or a StoreKit 2 JWS.");
      }

      try {
        normalized = await verifyLegacyReceipt(receiptData, transactionId, payload.planId, sharedSecret);
      } catch (e) {
        const err = e as Error & { appleStatus?: number; environment?: string };
        await logIapEvent(admin, {
          userId, event: 'verify_apple_rejected', level: 'error', transactionId,
          message: err.message,
          detail: { appleStatus: err.appleStatus, environment: err.environment },
        });
        return errorResponse(`Apple receipt validation failed: ${err.message}`, 422);
      }
    }

    const {
      valid, environment, appleStatus, matched, appleProductId, appleTransactionId,
      originalTransactionId, expiresDateMs, isExpired, subscriptionStatus, autoRenewStatus,
    } = normalized;

    const derivedPlanId = appleProductId ? APPLE_PRODUCT_TO_PLAN_ID[appleProductId] ?? null : null;
    const derivedTier = appleProductId ? APPLE_PRODUCT_TO_TIER[appleProductId] ?? null : null;

    let subscriptionRow: Record<string, unknown> | null = null;

    if (valid && !isExpired && appleProductId && appleTransactionId && derivedPlanId) {
      // Idempotent: StoreKit may redeliver the same transaction, and restore
      // calls hit this repeatedly - never double-write.
      const { data: existing } = await admin
        .from('user_subscriptions')
        .select()
        .eq('user_id', userId)
        .eq('payment_reference', appleTransactionId)
        .maybeSingle();

      if (existing) {
        subscriptionRow = existing;
      } else {
        const { data: plan } = await admin
          .from('subscription_plans')
          .select('price, currency, duration_days, name')
          .eq('id', derivedPlanId)
          .maybeSingle();

        const endDate = expiresDateMs
          ? new Date(parseInt(expiresDateMs))
          : new Date(Date.now() + (plan?.duration_days ?? 30) * 86400000);
        const now = new Date();

        // Expire any other active subscription before recording this one.
        await admin
          .from('user_subscriptions')
          .update({ status: 'expired', updated_at: now.toISOString() })
          .eq('user_id', userId)
          .eq('status', 'active');

        const { data: inserted, error: insertError } = await admin
          .from('user_subscriptions')
          .insert({
            user_id: userId,
            plan_id: derivedPlanId,
            tier: derivedTier,
            subscription_type: plan?.name ?? derivedPlanId,
            amount: plan?.price ?? 0,
            currency: plan?.currency ?? 'GHS',
            status: 'active',
            payment_reference: appleTransactionId,
            payment_method: 'apple_iap',
            transaction_id: appleTransactionId,
            original_transaction_id: originalTransactionId ?? appleTransactionId,
            platform: 'ios',
            auto_renew_status: autoRenewStatus,
            receipt_data: receiptData,
            start_date: now.toISOString(),
            end_date: endDate.toISOString(),
            is_auto_renew: true,
          })
          .select()
          .single();

        if (insertError) {
          console.error('Failed to write subscription:', insertError);
          await logIapEvent(admin, {
            userId, event: 'verify_db_write_failed', level: 'error',
            transactionId: appleTransactionId, productId: appleProductId,
            message: insertError.message,
            detail: { derivedPlanId, derivedTier },
          });
          return errorResponse(`Verified but failed to activate subscription: ${insertError.message}`, 500);
        }
        subscriptionRow = inserted;

        await admin.from('subscription_payments').insert({
          user_id: userId,
          subscription_id: inserted.id,
          amount: plan?.price ?? 0,
          currency: plan?.currency ?? 'GHS',
          payment_reference: appleTransactionId,
          payment_method: 'apple_iap',
          payment_status: 'success',
          payment_date: now.toISOString(),
          metadata: {
            product_id: appleProductId,
            plan_id: derivedPlanId,
            verified: true,
            source: 'app_store',
            environment,
          },
        });
      }
    }

    const response: EnhancedResponse = {
      valid,
      environment,
      status: appleStatus,
      matchedTransaction: matched,
      productId: appleProductId,
      transactionId: appleTransactionId,
      originalTransactionId: originalTransactionId ?? null,
      expiresDateMs: expiresDateMs ?? null,
      isExpired,
      subscriptionStatus,
      autoRenewStatus,
      planId: derivedPlanId,
      userId,
      subscription: subscriptionRow,
      timestamp: new Date().toISOString(),
    };

    console.log(`Receipt verification completed: valid=${valid}, status=${subscriptionStatus}, expired=${isExpired}, wrote=${!!subscriptionRow}`);
    await logIapEvent(admin, {
      userId, event: 'verify_result', transactionId: appleTransactionId, productId: appleProductId,
      message: `valid=${valid} status=${subscriptionStatus} wrote=${!!subscriptionRow}`,
      detail: { valid, subscriptionStatus, isExpired, matched, environment, wroteRow: !!subscriptionRow },
    });

    return new Response(JSON.stringify(response), {
      headers: jsonHeaders,
      status: valid ? 200 : 422,
    });
  } catch (e) {
    const errorMessage = e instanceof Error ? e.message : String(e);
    console.error(`Receipt verification error: ${errorMessage}`);
    await logIapEvent(admin, {
      userId: payload.userId, event: 'verify_exception', level: 'error',
      transactionId: payload.transactionId,
      message: errorMessage,
    });
    return errorResponse(`Verification error: ${errorMessage}`, 502);
  }
});
