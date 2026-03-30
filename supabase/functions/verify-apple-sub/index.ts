/**
 * ============================================================================
 * Supabase Edge Function: verify-apple-sub
 * ============================================================================
 * Purpose: Verify Apple In-App Purchase receipts and store subscription state
 *
 * Flow:
 * 1. Receive receipt from Flutter app
 * 2. Verify with Apple (production or sandbox)
 * 3. Parse subscription details
 * 4. Upsert to Supabase database
 * 5. Return subscription status to app
 *
 * Environment Variables Required:
 * - SUPABASE_URL
 * - SUPABASE_SERVICE_ROLE_KEY
 * - APPLE_SHARED_SECRET (from App Store Connect)
 * ============================================================================
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// ============================================================================
// Types and Interfaces
// ============================================================================

interface VerifyRequest {
  receiptData: string;  // Base64 encoded receipt
  userId: string;       // Supabase user ID
  sandbox?: boolean;    // Optional: force sandbox mode
}

interface AppleReceiptResponse {
  status: number;
  receipt?: any;
  latest_receipt_info?: any[];
  latest_receipt?: string;
  pending_renewal_info?: any[];
  environment?: string;
}

interface SubscriptionData {
  user_id: string;
  platform: string;
  product_id: string;
  original_transaction_id: string;
  latest_transaction_id: string;
  status: string;
  sandbox: boolean;
  purchase_date: string | null;
  expires_at: string | null;
  auto_renew_enabled: boolean;
  apple_receipt_data: string;
  apple_latest_receipt: string | null;
}

// ============================================================================
// Apple Receipt Verification
// ============================================================================

async function verifyWithApple(
  receiptData: string,
  sharedSecret: string,
  useSandbox: boolean = false
): Promise<AppleReceiptResponse> {
  const endpoint = useSandbox
    ? 'https://sandbox.itunes.apple.com/verifyReceipt'
    : 'https://buy.itunes.apple.com/verifyReceipt';

  console.log(`Verifying with Apple (${useSandbox ? 'SANDBOX' : 'PRODUCTION'})`);

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      'receipt-data': receiptData,
      'password': sharedSecret,
      'exclude-old-transactions': false,
    }),
  });

  if (!response.ok) {
    throw new Error(`Apple API request failed: ${response.statusText}`);
  }

  const data: AppleReceiptResponse = await response.json();
  console.log(`Apple response status: ${data.status}`);

  return data;
}

// ============================================================================
// Parse Apple Response
// ============================================================================

function parseAppleResponse(appleResponse: AppleReceiptResponse, receiptData: string): SubscriptionData | null {
  // Status codes reference:
  // 0: Valid receipt
  // 21000-21010: Various errors
  // 21007: Receipt is from sandbox (sent to production endpoint)

  if (appleResponse.status !== 0) {
    console.error(`Apple returned error status: ${appleResponse.status}`);
    return null;
  }

  // Get latest transaction from latest_receipt_info array
  const latestReceiptInfo = appleResponse.latest_receipt_info;
  if (!latestReceiptInfo || latestReceiptInfo.length === 0) {
    console.error('No subscription info in receipt');
    return null;
  }

  // Sort by expires_date_ms to get the most recent
  const sortedTransactions = latestReceiptInfo.sort((a, b) => {
    const aExpires = parseInt(a.expires_date_ms || '0');
    const bExpires = parseInt(b.expires_date_ms || '0');
    return bExpires - aExpires;  // Descending order
  });

  const latestTransaction = sortedTransactions[0];

  // Check if subscription is currently active
  const expiresMs = parseInt(latestTransaction.expires_date_ms);
  const now = Date.now();
  const isActive = expiresMs > now;

  // Check auto-renew status from pending_renewal_info
  let autoRenewEnabled = true;  // Default to true
  if (appleResponse.pending_renewal_info && appleResponse.pending_renewal_info.length > 0) {
    const renewalInfo = appleResponse.pending_renewal_info[0];
    autoRenewEnabled = renewalInfo.auto_renew_status === '1';
  }

  // Determine subscription status
  let status: string;
  if (isActive) {
    status = 'active';
  } else {
    // Check if was refunded
    if (latestTransaction.cancellation_date_ms) {
      status = 'refunded';
    } else {
      status = 'expired';
    }
  }

  // Determine if sandbox
  const isSandbox = appleResponse.environment === 'Sandbox';

  return {
    user_id: '', // Will be filled by caller
    platform: 'ios',
    product_id: latestTransaction.product_id,
    original_transaction_id: latestTransaction.original_transaction_id,
    latest_transaction_id: latestTransaction.transaction_id,
    status: status,
    sandbox: isSandbox,
    purchase_date: new Date(parseInt(latestTransaction.purchase_date_ms)).toISOString(),
    expires_at: new Date(parseInt(latestTransaction.expires_date_ms)).toISOString(),
    auto_renew_enabled: autoRenewEnabled,
    apple_receipt_data: receiptData,
    apple_latest_receipt: appleResponse.latest_receipt || null,
  };
}

// ============================================================================
// Database Operations
// ============================================================================

async function upsertSubscription(
  supabase: any,
  subscriptionData: SubscriptionData
): Promise<{ success: boolean; error?: string }> {
  try {
    // Upsert using latest_transaction_id as unique key
    // This handles both new subscriptions and renewals
    const { data, error } = await supabase
      .from('subscriptions')
      .upsert(
        subscriptionData,
        {
          onConflict: 'latest_transaction_id',
          ignoreDuplicates: false,
        }
      )
      .select()
      .single();

    if (error) {
      console.error('Database upsert error:', error);
      return { success: false, error: error.message };
    }

    console.log('Subscription upserted successfully:', data.id);

    // Log event to subscription_events table
    await supabase.from('subscription_events').insert({
      subscription_id: data.id,
      user_id: subscriptionData.user_id,
      event_type: subscriptionData.status === 'active' ? 'renewed' : 'expired',
      platform: 'ios',
      product_id: subscriptionData.product_id,
      transaction_id: subscriptionData.latest_transaction_id,
      details: {
        sandbox: subscriptionData.sandbox,
        auto_renew: subscriptionData.auto_renew_enabled,
      },
    });

    return { success: true };
  } catch (err) {
    console.error('Database operation failed:', err);
    return { success: false, error: String(err) };
  }
}

// ============================================================================
// Main Handler
// ============================================================================

serve(async (req) => {
  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // ========================================================================
    // 1. Parse Request
    // ========================================================================
    const requestBody: VerifyRequest = await req.json();
    const { receiptData, userId, sandbox = false } = requestBody;

    if (!receiptData || !userId) {
      return new Response(
        JSON.stringify({
          success: false,
          isSubscribed: false,
          errorCode: 'missing_parameters',
          message: 'receiptData and userId are required',
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // ========================================================================
    // 2. Get Environment Variables
    // ========================================================================
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const appleSharedSecret = Deno.env.get('APPLE_SHARED_SECRET');

    if (!appleSharedSecret) {
      console.error('APPLE_SHARED_SECRET not configured');
      return new Response(
        JSON.stringify({
          success: false,
          isSubscribed: false,
          errorCode: 'server_configuration_error',
          message: 'Apple shared secret not configured',
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Create Supabase client with service role (bypasses RLS)
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // ========================================================================
    // 3. Verify with Apple
    // ========================================================================
    let appleResponse: AppleReceiptResponse;

    try {
      // Try production first (unless sandbox is explicitly requested)
      appleResponse = await verifyWithApple(receiptData, appleSharedSecret, sandbox);

      // Handle status 21007: sandbox receipt sent to production
      if (appleResponse.status === 21007) {
        console.log('Receipt is sandbox, retrying with sandbox endpoint');
        appleResponse = await verifyWithApple(receiptData, appleSharedSecret, true);
      }
    } catch (error) {
      console.error('Apple verification failed:', error);
      return new Response(
        JSON.stringify({
          success: false,
          isSubscribed: false,
          errorCode: 'apple_verification_failed',
          message: String(error),
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // ========================================================================
    // 4. Parse Apple Response
    // ========================================================================
    const subscriptionData = parseAppleResponse(appleResponse, receiptData);

    if (!subscriptionData) {
      return new Response(
        JSON.stringify({
          success: false,
          isSubscribed: false,
          errorCode: 'invalid_receipt',
          appleStatus: appleResponse.status,
          message: 'Receipt validation failed or no active subscription',
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Set user_id from request
    subscriptionData.user_id = userId;

    // ========================================================================
    // 5. Store in Database
    // ========================================================================
    const dbResult = await upsertSubscription(supabase, subscriptionData);

    if (!dbResult.success) {
      return new Response(
        JSON.stringify({
          success: false,
          isSubscribed: false,
          errorCode: 'database_error',
          message: dbResult.error,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // ========================================================================
    // 6. Return Success Response
    // ========================================================================
    return new Response(
      JSON.stringify({
        success: true,
        isSubscribed: subscriptionData.status === 'active',
        platform: 'ios',
        productId: subscriptionData.product_id,
        expiry: subscriptionData.expires_at,
        sandbox: subscriptionData.sandbox,
        autoRenewEnabled: subscriptionData.auto_renew_enabled,
        status: subscriptionData.status,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );

  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        isSubscribed: false,
        errorCode: 'internal_error',
        message: String(error),
      }),
      {
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json',
        },
      }
    );
  }
});
