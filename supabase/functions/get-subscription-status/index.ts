/**
 * ============================================================================
 * Supabase Edge Function: get-subscription-status
 * ============================================================================
 * Purpose: Check current subscription status for a user
 *
 * Flow:
 * 1. Receive userId from app
 * 2. Query subscriptions table for active subscription
 * 3. Return subscription details or false
 *
 * This function is called:
 * - On app startup
 * - When user navigates to subscription/premium screens
 * - After a successful purchase to refresh status
 *
 * Environment Variables Required:
 * - SUPABASE_URL
 * - SUPABASE_SERVICE_ROLE_KEY
 * ============================================================================
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// ============================================================================
// Types
// ============================================================================

interface StatusRequest {
  userId: string;
}

interface SubscriptionStatus {
  isSubscribed: boolean;
  productId?: string;
  expiry?: string;
  platform?: string;
  status?: string;
  autoRenewEnabled?: boolean;
  sandbox?: boolean;
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
    // 1. Parse Request (Support both POST and GET)
    // ========================================================================
    let userId: string;

    if (req.method === 'POST') {
      const requestBody: StatusRequest = await req.json();
      userId = requestBody.userId;
    } else if (req.method === 'GET') {
      const url = new URL(req.url);
      userId = url.searchParams.get('userId') || '';
    } else {
      return new Response(
        JSON.stringify({
          isSubscribed: false,
          error: 'Method not allowed. Use POST or GET.',
        }),
        {
          status: 405,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    if (!userId) {
      return new Response(
        JSON.stringify({
          isSubscribed: false,
          error: 'userId parameter is required',
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // ========================================================================
    // 2. Initialize Supabase Client
    // ========================================================================
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    // Use service role to bypass RLS
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // ========================================================================
    // 3. Query Active Subscription
    // ========================================================================

    // Method 1: Use the helper function we created
    const { data: functionResult, error: functionError } = await supabase
      .rpc('get_user_subscription', { p_user_id: userId });

    if (functionError) {
      console.error('Function call error:', functionError);

      // Fallback: Query directly if function fails
      const { data: subscriptions, error: queryError } = await supabase
        .from('subscriptions')
        .select('*')
        .eq('user_id', userId)
        .in('status', ['active', 'grace_period'])
        .or(`expires_at.is.null,expires_at.gt.${new Date().toISOString()}`)
        .order('expires_at', { ascending: false, nullsFirst: true })
        .limit(1);

      if (queryError) {
        console.error('Direct query error:', queryError);
        return new Response(
          JSON.stringify({
            isSubscribed: false,
            error: 'Database query failed',
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        );
      }

      if (!subscriptions || subscriptions.length === 0) {
        return new Response(
          JSON.stringify({
            isSubscribed: false,
          }),
          {
            status: 200,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        );
      }

      const sub = subscriptions[0];
      return new Response(
        JSON.stringify({
          isSubscribed: true,
          productId: sub.product_id,
          expiry: sub.expires_at,
          platform: sub.platform,
          status: sub.status,
          autoRenewEnabled: sub.auto_renew_enabled,
          sandbox: sub.sandbox,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Function executed successfully
    if (!functionResult || functionResult.length === 0 || !functionResult[0].is_subscribed) {
      return new Response(
        JSON.stringify({
          isSubscribed: false,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // ========================================================================
    // 4. Return Subscription Status
    // ========================================================================
    const result = functionResult[0];

    const response: SubscriptionStatus = {
      isSubscribed: result.is_subscribed,
      productId: result.product_id,
      expiry: result.expires_at,
      platform: result.platform,
      status: result.status,
      autoRenewEnabled: result.auto_renew_enabled,
    };

    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );

  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({
        isSubscribed: false,
        error: String(error),
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
