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

import { createClient } from 'npm:@supabase/supabase-js@2'

type VerifyRequest = {
  userId: string;
  planId?: string; // client hint only, never trusted for the DB write
  transactionId?: string; // optional: omitted for restore/resync calls
  receiptData: string; // base64 string
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

Deno.serve(async (req: Request) => {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin = createClient(supabaseUrl, serviceRoleKey);
  let payload: Partial<VerifyRequest> = {};

  try {
    if (req.method !== "POST") {
      return errorResponse("Method not allowed", 405);
    }

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

    // Validate receipt data format
    try {
      atob(receiptData); // Test if it's valid base64
    } catch {
      await logIapEvent(admin, {
        userId, event: 'verify_bad_request', level: 'error', transactionId,
        message: 'Invalid receipt data format (not base64)',
      });
      return errorResponse("Invalid receipt data format. Must be base64 encoded.");
    }

    // First attempt: Production
    let apple = await verifyWithApple(APPLE_PRODUCTION_URL, receiptData, sharedSecret);
    let environment = "Production";

    // If this is a sandbox receipt in production, switch to sandbox per Apple docs
    if (apple.status === 21007) {
      console.log("Sandbox receipt detected, switching to sandbox environment");
      apple = await verifyWithApple(APPLE_SANDBOX_URL, receiptData, sharedSecret);
      environment = "Sandbox";
    }

    // Handle specific error cases
    if (apple.status !== 0 && apple.status !== 21006) {
      const errorMessage = APPLE_STATUS_CODES[apple.status] || `Unknown Apple status: ${apple.status}`;
      await logIapEvent(admin, {
        userId, event: 'verify_apple_rejected', level: 'error', transactionId,
        message: errorMessage,
        detail: { appleStatus: apple.status, environment },
      });
      return errorResponse(`Apple receipt validation failed: ${errorMessage}`, 422);
    }

    // Build response with enhanced information. Client's planId is used
    // only as a hint for matching when neither transactionId nor a
    // productId-derived match is available - the actual DB write below
    // always uses Apple's own confirmed product_id.
    const clientProductHint = payload.planId
      ? Object.entries(APPLE_PRODUCT_TO_PLAN_ID).find(([, v]) => v === payload.planId)?.[0]
      : undefined;
    const { match, matched } = findMatchingInfo(apple, transactionId, clientProductHint);
    const valid = apple.status === 0 || apple.status === 21006; // 21006 means valid but expired

    const { isExpired, subscriptionStatus, autoRenewStatus } = determineSubscriptionStatus(
      match,
      apple.pending_renewal_info
    );

    const appleProductId = match?.product_id as string | undefined ?? null;
    const appleTransactionId = match?.transaction_id as string | undefined ?? null;
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

        const expiresDateMs = match?.expires_date_ms as string | undefined;
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
            original_transaction_id: (match?.original_transaction_id as string | undefined) ?? appleTransactionId,
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
      environment: apple.environment ?? environment,
      status: apple.status,
      matchedTransaction: matched,
      productId: appleProductId,
      transactionId: appleTransactionId,
      originalTransactionId: match?.original_transaction_id as string ?? null,
      expiresDateMs: match?.expires_date_ms as string ?? null,
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
