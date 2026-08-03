// @ts-nocheck
// S2: server-side free trial activation. The client used to check
// eligibility (no prior trial, no active subscription) and then insert the
// trial row itself - both the check and the write were client-controlled,
// so a user could just call startFreeTrial() repeatedly, or skip the check
// and POST an 'active' row directly. Eligibility is now re-verified here
// against the real database, and only this function (service role) can
// write the row.

import { createClient } from 'npm:@supabase/supabase-js@2'

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type' } })
  }
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  const admin = createClient(supabaseUrl, serviceRoleKey)

  const authHeader = req.headers.get('Authorization') ?? ''
  const jwt = authHeader.replace(/^Bearer\s+/i, '')
  if (!jwt) return jsonResponse({ error: 'Missing Authorization header' }, 401)
  const { data: callerData, error: callerError } = await admin.auth.getUser(jwt)
  if (callerError || !callerData?.user) return jsonResponse({ error: 'Invalid session' }, 401)
  const userId = callerData.user.id

  const { data: usedTrial } = await admin
    .from('user_subscriptions')
    .select('id')
    .eq('user_id', userId)
    .eq('subscription_type', '3-Day Free Trial')
    .maybeSingle()
  if (usedTrial) {
    return jsonResponse({ error: 'Free trial has already been used' }, 409)
  }

  const { data: activeSub } = await admin
    .from('user_subscriptions')
    .select('id')
    .eq('user_id', userId)
    .eq('status', 'active')
    .maybeSingle()
  if (activeSub) {
    return jsonResponse({ error: 'An active subscription already exists' }, 409)
  }

  const now = new Date()
  const endDate = new Date(now.getTime() + 3 * 86400000)

  const { data: sub, error: insertError } = await admin
    .from('user_subscriptions')
    .insert({
      user_id: userId,
      plan_id: 'weekly_plan',
      tier: 'Gold',
      subscription_type: '3-Day Free Trial',
      billing_cycle: 'monthly',
      amount: 0,
      currency: 'GHS',
      status: 'active',
      payment_method: 'free_trial',
      start_date: now.toISOString(),
      end_date: endDate.toISOString(),
      is_auto_renew: false,
    })
    .select()
    .single()

  if (insertError) {
    console.error('Failed to create trial subscription:', insertError)
    return jsonResponse({ error: 'Failed to start free trial' }, 500)
  }

  return jsonResponse({ success: true, subscription: sub })
})
