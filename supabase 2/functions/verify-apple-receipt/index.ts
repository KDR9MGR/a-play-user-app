/// <reference lib="deno.ns" />
/// <reference lib="dom" />
// Supabase Edge Function: verify-apple-receipt
// Enhanced Apple App Store receipt validation with production-ready features
// Validates receipts, handles subscription status, and provides detailed error reporting

type VerifyRequest = {
  userId: string;
  planId: string;
  transactionId: string;
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
  planId: string;
  userId: string;
  error?: string;
  timestamp: string;
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
) {
  const infos = apple.latest_receipt_info ?? [];
  
  if (transactionId) {
    const match = infos.find((i) => i?.transaction_id === transactionId);
    if (match) {
      console.log(`Found matching transaction: ${transactionId}`);
      return { match, matched: true };
    }
    console.log(`Transaction ${transactionId} not found, using latest transaction`);
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
  try {
    if (req.method !== "POST") {
      return errorResponse("Method not allowed", 405);
    }

    const sharedSecret =
      Deno.env.get("APPLE_SHARED_SECRET") || Deno.env.get("IOS_SHARED_SECRET") || "";
    if (!sharedSecret) {
      return errorResponse(
        "Missing APPLE_SHARED_SECRET. Set with `supabase secrets set APPLE_SHARED_SECRET=...`",
        500,
      );
    }

    const payload = (await req.json()) as Partial<VerifyRequest>;
    const { userId, planId, transactionId, receiptData } = payload;

    if (!userId || !planId || !transactionId || !receiptData) {
      return errorResponse("Missing required fields: userId, planId, transactionId, receiptData");
    }

    console.log(`Processing receipt verification for user: ${userId}, plan: ${planId}, transaction: ${transactionId}`);

    // Validate receipt data format
    try {
      atob(receiptData); // Test if it's valid base64
    } catch {
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
      return errorResponse(`Apple receipt validation failed: ${errorMessage}`, 422);
    }

    // Build response with enhanced information
    const { match, matched } = findMatchingInfo(apple, transactionId);
    const valid = apple.status === 0 || apple.status === 21006; // 21006 means valid but expired
    
    const { isExpired, subscriptionStatus, autoRenewStatus } = determineSubscriptionStatus(
      match, 
      apple.pending_renewal_info
    );

    const response: EnhancedResponse = {
      valid,
      environment: apple.environment ?? environment,
      status: apple.status,
      matchedTransaction: matched,
      productId: match?.product_id as string ?? null,
      transactionId: match?.transaction_id as string ?? null,
      originalTransactionId: match?.original_transaction_id as string ?? null,
      expiresDateMs: match?.expires_date_ms as string ?? null,
      isExpired,
      subscriptionStatus,
      autoRenewStatus,
      planId,
      userId,
      timestamp: new Date().toISOString(),
    };

    console.log(`Receipt verification completed: valid=${valid}, status=${subscriptionStatus}, expired=${isExpired}`);

    return new Response(JSON.stringify(response), {
      headers: jsonHeaders,
      status: valid ? 200 : 422,
    });
  } catch (e) {
    const errorMessage = e instanceof Error ? e.message : String(e);
    console.error(`Receipt verification error: ${errorMessage}`);
    return errorResponse(`Verification error: ${errorMessage}`, 502);
  }
});