/// <reference lib="deno.ns" />
/// <reference lib="dom" />
// Supabase Edge Function: apple-webhook
// Receives Apple's App Store Server Notifications V2 (renewals, cancellations,
// refunds, billing retry/grace period, auto-renew toggles) and keeps
// `user_subscriptions` in sync after the initial purchase.
//
// S1 (2026-08-17): rewritten from scratch. The previous version had two bugs
// that meant it had never actually done anything useful since it was
// deployed:
//   1. It looked up and updated a table called `subscriptions`, which is a
//      different, entirely empty table that nothing else in the app reads
//      from. The table the rest of the app actually reads/writes is
//      `user_subscriptions` (10 real rows). Every notification Apple has
//      ever sent this endpoint hit the "not found" branch and did nothing -
//      a refund would never have unset a user's access, a renewal would
//      never have extended it.
//   2. It decoded the signed JWS payload without ever verifying its
//      signature - anyone who found this URL could POST a forged
//      notification and have it accepted at face value. This reuses the
//      exact same pinned-root-CA + x5c-chain verification already built and
//      tested for verify-apple-receipt.

import 'npm:reflect-metadata';
import { createClient } from 'npm:@supabase/supabase-js@2'
import { importX509, compactVerify } from 'npm:jose@5'
import { X509Certificate, BasicConstraintsExtension } from 'npm:@peculiar/x509@1'

const jsonHeaders = {
  "content-type": "application/json",
  "cache-control": "no-store",
};

const EXPECTED_BUNDLE_ID = 'com.a.aPlayWorld';

// Same pin used in verify-apple-receipt - see that file for provenance
// (downloaded directly from apple.com/certificateauthority, sha256
// fingerprint verified against the openssl output at the time).
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

const APPLE_LEAF_POLICY_OID = '1.2.840.113635.100.6.11.1';
const APPLE_INTERMEDIATE_POLICY_OID = '1.2.840.113635.100.6.2.1';

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

// Identical logic (and identical test coverage) to verifyAppleCertChain in
// verify-apple-receipt/index.ts: mirrors apple/app-store-server-library-node
// exactly (x5c must have exactly 3 certs, only certs [0] and [1] are used
// cryptographically, the intermediate must chain to our pinned root by
// signature AND issuer/subject match, CA basic-constraint required, Apple's
// own policy OIDs required, full validity-window check).
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

// Verifies and decodes any Apple-signed JWS (the outer notification
// envelope, or the nested signedTransactionInfo/signedRenewalInfo - all
// three are independently-signed JWS compact strings using this same x5c
// structure).
async function verifyAndDecodeAppleJWS<T>(jws: string): Promise<T> {
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
  return JSON.parse(new TextDecoder().decode(payload)) as T;
}

type NotificationEnvelope = {
  notificationType: string;
  subtype?: string;
  notificationUUID: string;
  data?: {
    bundleId?: string;
    environment?: 'Sandbox' | 'Production';
    signedTransactionInfo?: string;
    signedRenewalInfo?: string;
  };
};

type TransactionPayload = {
  transactionId: string;
  originalTransactionId: string;
  bundleId: string;
  productId: string;
  expiresDate?: number;
  purchaseDate?: number;
  revocationDate?: number;
  environment: 'Sandbox' | 'Production';
};

type RenewalInfoPayload = {
  originalTransactionId: string;
  autoRenewProductId?: string;
  productId: string;
  autoRenewStatus: 0 | 1;
  isInBillingRetryPeriod?: boolean;
  gracePeriodExpiresDate?: number;
  expirationIntent?: number;
};

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
  console.error(`apple-webhook error: ${message}`);
  return new Response(JSON.stringify({ ok: false, error: message }), {
    headers: jsonHeaders,
    status,
  });
}

Deno.serve(async (req: Request) => {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin = createClient(supabaseUrl, serviceRoleKey);

  if (req.method !== 'POST') {
    return errorResponse('Method not allowed', 405);
  }

  let notificationType = 'unknown';
  try {
    const body = await req.json().catch(() => ({}));
    const signedPayload = body?.signedPayload;
    if (!signedPayload || typeof signedPayload !== 'string') {
      return errorResponse('Missing signedPayload', 400);
    }

    const envelope = await verifyAndDecodeAppleJWS<NotificationEnvelope>(signedPayload);
    notificationType = envelope.notificationType?.toUpperCase() ?? 'unknown';
    const subtype = envelope.subtype?.toUpperCase() ?? null;
    const data = envelope.data;

    if (!data?.bundleId || data.bundleId !== EXPECTED_BUNDLE_ID) {
      await logIapEvent(admin, {
        event: 'webhook_bundle_mismatch', level: 'error',
        message: `notification bundleId "${data?.bundleId}" does not match app bundleId`,
      });
      return errorResponse('Bundle ID mismatch', 422);
    }

    let transaction: TransactionPayload | null = null;
    let renewal: RenewalInfoPayload | null = null;

    if (data.signedTransactionInfo) {
      transaction = await verifyAndDecodeAppleJWS<TransactionPayload>(data.signedTransactionInfo);
    }
    if (data.signedRenewalInfo) {
      renewal = await verifyAndDecodeAppleJWS<RenewalInfoPayload>(data.signedRenewalInfo);
    }

    const originalTransactionId = transaction?.originalTransactionId ?? renewal?.originalTransactionId ?? null;
    if (!originalTransactionId) {
      await logIapEvent(admin, {
        event: 'webhook_missing_original_transaction_id', level: 'warn',
        message: notificationType,
      });
      // Nothing actionable, but this is a well-formed, genuinely
      // Apple-signed notification we're choosing not to act on - 200 so
      // Apple doesn't keep retrying it.
      return new Response(JSON.stringify({ ok: true, handled: false, reason: 'missing_original_transaction_id' }), {
        headers: jsonHeaders,
        status: 200,
      });
    }

    // Look up the live row in user_subscriptions - the table the rest of
    // the app (SubscriptionSync, get-subscription-status) actually reads.
    const { data: existing, error: findError } = await admin
      .from('user_subscriptions')
      .select('id, user_id, status')
      .eq('original_transaction_id', originalTransactionId)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (findError) {
      await logIapEvent(admin, {
        event: 'webhook_db_lookup_failed', level: 'error', message: findError.message,
        transactionId: originalTransactionId,
      });
      return errorResponse('Database lookup failed', 500);
    }

    if (!existing) {
      // Genuine, verified Apple notification, but we have no matching
      // subscription yet (e.g. the initial verify-apple-receipt call hasn't
      // landed, or this is a sandbox notification for a different
      // account). 200 so Apple doesn't retry indefinitely.
      return new Response(JSON.stringify({ ok: true, handled: false, reason: 'subscription_not_found' }), {
        headers: jsonHeaders,
        status: 200,
      });
    }

    const now = Date.now();
    const updatePayload: Record<string, unknown> = {
      updated_at: new Date().toISOString(),
    };

    switch (notificationType) {
      case 'DID_RENEW': {
        updatePayload.status = 'active';
        break;
      }
      case 'DID_FAIL_TO_RENEW': {
        updatePayload.status = subtype === 'GRACE_PERIOD' ? 'grace_period' : 'billing_retry';
        break;
      }
      case 'GRACE_PERIOD_EXPIRED': {
        updatePayload.status = 'expired';
        break;
      }
      case 'EXPIRED': {
        updatePayload.status = 'expired';
        break;
      }
      case 'REFUND':
      case 'REVOKE': {
        updatePayload.status = 'refunded';
        // Revoked/refunded access ends now, regardless of what the
        // transaction's original expiresDate said.
        updatePayload.end_date = new Date().toISOString();
        break;
      }
      case 'DID_CHANGE_RENEWAL_STATUS': {
        // Auto-renew toggled on/off - doesn't end access immediately,
        // just changes whether it will renew at period end.
        if (renewal) {
          updatePayload.is_auto_renew = renewal.autoRenewStatus === 1;
          updatePayload.auto_renew_status = renewal.autoRenewStatus === 1;
        }
        break;
      }
      case 'DID_CHANGE_RENEWAL_PREF':
      case 'PRICE_INCREASE':
      case 'OFFER_REDEEMED':
      case 'RENEWAL_EXTENDED':
      case 'SUBSCRIBED': {
        // Informational / already handled by verify-apple-receipt on the
        // initial purchase - just record the event below, no status change.
        break;
      }
      default: {
        // Unrecognized type - log it but don't guess at a status change.
        break;
      }
    }

    if (transaction?.expiresDate && (notificationType === 'DID_RENEW' || notificationType === 'SUBSCRIBED')) {
      updatePayload.end_date = new Date(transaction.expiresDate).toISOString();
    }
    if (transaction?.transactionId) {
      updatePayload.transaction_id = transaction.transactionId;
    }

    if (Object.keys(updatePayload).length > 1) {
      const { error: updateError } = await admin
        .from('user_subscriptions')
        .update(updatePayload)
        .eq('id', existing.id);

      if (updateError) {
        await logIapEvent(admin, {
          userId: existing.user_id, event: 'webhook_db_update_failed', level: 'error',
          message: updateError.message, transactionId: originalTransactionId,
        });
        return errorResponse('Database update failed', 500);
      }
    }

    // subscription_events.subscription_id has a FK into the old, unused
    // `subscriptions` table - deliberately left null here rather than
    // pointing it at a row in a different table. user_id/transaction_id/
    // details are enough to trace this event.
    await admin.from('subscription_events').insert({
      id: crypto.randomUUID(),
      subscription_id: null,
      user_id: existing.user_id,
      event_type: notificationType.toLowerCase(),
      platform: 'ios',
      product_id: transaction?.productId ?? renewal?.productId ?? null,
      transaction_id: transaction?.transactionId ?? null,
      details: { subtype, environment: data.environment, transaction, renewal },
    });

    await logIapEvent(admin, {
      userId: existing.user_id, event: 'webhook_processed',
      productId: transaction?.productId ?? renewal?.productId,
      transactionId: originalTransactionId,
      message: `${notificationType}${subtype ? ` (${subtype})` : ''} -> ${updatePayload.status ?? existing.status}`,
      detail: { notificationType, subtype, environment: data.environment },
    });

    return new Response(JSON.stringify({ ok: true, handled: true }), {
      headers: jsonHeaders,
      status: 200,
    });
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    await logIapEvent(admin, {
      event: 'webhook_exception', level: 'error', message,
      detail: { notificationType },
    });
    return errorResponse(`Verification or processing error: ${message}`, 502);
  }
});
