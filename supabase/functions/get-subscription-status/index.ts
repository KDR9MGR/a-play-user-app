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
    // 3. Query Active Subscription from user_subscriptions table
    // ========================================================================

    console.log('Checking subscription for user:', userId);

    // Query user_subscriptions table directly (where IAP data is stored)
    const { data: subscriptions, error: queryError } = await supabase
      .from('user_subscriptions')
      .select('*')
      .eq('user_id', userId)
      .eq('status', 'active')
      .gt('end_date', new Date().toISOString())
      .order('created_at', { ascending: false })
      .limit(1);

    if (queryError) {
      console.error('Query error:', queryError);
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

    // No active subscription found
    if (!subscriptions || subscriptions.length === 0) {
      console.log('No active subscription found for user:', userId);
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
    const sub = subscriptions[0];
    console.log('Active subscription found:', {
      product_id: sub.product_id,
      status: sub.status,
      expires: sub.end_date,
    });

    const response: SubscriptionStatus = {
      isSubscribed: true,
      productId: sub.product_id,
      expiry: sub.end_date, // Changed from expires_at to end_date
      platform: sub.platform,
      status: sub.status,
      autoRenewEnabled: sub.auto_renew_enabled,
      sandbox: sub.sandbox,
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
