// @ts-nocheck
// S2/S4: server-side purchase fulfillment for Paystack event-ticket bookings
// and subscriptions. The client used to insert `bookings`/`user_subscriptions`
// rows itself after merely asking Paystack "was this reference paid" - which
// meant the CONTENTS of what got created (which zone, how many tickets, which
// plan) were never actually tied to what was paid for. A user could verify a
// cheap reference and then insert an expensive booking/subscription with it,
// or just POST to /rest/v1/bookings directly with no payment at all.
//
// This function is now the only way those rows get created by a client
// request: it re-verifies the reference with Paystack itself (never trusts
// the client's report of "payment succeeded"), and builds the row EXCLUSIVELY
// from what `payment_intents` recorded when `paystack/initialize` computed
// the real price - never from anything the client sends here.

import { createClient } from 'npm:@supabase/supabase-js@2'

// Temporary validation toggle: when PAYSTACK_TEST_MODE=true, verify against
// Paystack's sandbox using PAYSTACK_TEST_SECRET_KEY instead of the live key -
// must stay in sync with the same toggle in paystack/index.ts, since a
// reference initialized in test mode can only be verified with the test key.
function resolvePaystackSecretKey(): string | undefined {
  const testMode = (Deno.env.get('PAYSTACK_TEST_MODE') ?? '').toLowerCase() === 'true'
  return testMode ? Deno.env.get('PAYSTACK_TEST_SECRET_KEY') : Deno.env.get('PAYSTACK_SECRET_KEY')
}

// Mirrors APPLE_PRODUCT_TO_TIER in verify-apple-receipt/index.ts, keyed by
// plan_id instead of Apple's product_id. Without this, user_subscriptions.tier
// stays null on a Paystack purchase - is_subscribed still flips true (the
// profiles-sync trigger only cares whether a row is active), but the tier
// badge/gating that reads subscription_tier has nothing to show.
const PLAN_ID_TO_TIER: Record<string, string> = {
  weekly_plan: 'Gold',
  monthly_plan: 'Platinum',
  quarterly_plan: 'Platinum',
  annual_plan: 'Black',
}

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

  const paystackSecretKey = resolvePaystackSecretKey()
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  if (!paystackSecretKey) {
    return jsonResponse({ error: 'Paystack secret key is not configured for the active mode' }, 500)
  }

  const admin = createClient(supabaseUrl, serviceRoleKey)

  let body: Record<string, unknown>
  try {
    body = await req.json()
  } catch {
    return jsonResponse({ error: 'Invalid JSON body' }, 400)
  }

  const reference = body.reference
  if (typeof reference !== 'string' || !reference) {
    return jsonResponse({ error: 'reference is required' }, 400)
  }

  // Identify the caller and require them to own the payment intent.
  const authHeader = req.headers.get('Authorization') ?? ''
  const jwt = authHeader.replace(/^Bearer\s+/i, '')
  if (!jwt) return jsonResponse({ error: 'Missing Authorization header' }, 401)
  const { data: callerData, error: callerError } = await admin.auth.getUser(jwt)
  if (callerError || !callerData?.user) return jsonResponse({ error: 'Invalid session' }, 401)
  const callerId = callerData.user.id

  const { data: intent, error: intentError } = await admin
    .from('payment_intents')
    .select('*')
    .eq('reference', reference)
    .maybeSingle()

  if (intentError || !intent) {
    return jsonResponse({ error: 'No payment intent found for this reference' }, 404)
  }
  if (intent.user_id && intent.user_id !== callerId) {
    return jsonResponse({ error: 'This payment reference does not belong to you' }, 403)
  }

  // Idempotency: if this reference was already fulfilled, return the existing result.
  const { data: existingPayment } = await admin
    .from('subscription_payments')
    .select('subscription_id')
    .eq('payment_reference', reference)
    .maybeSingle()
  if (existingPayment) {
    return jsonResponse({ success: true, type: 'subscription', id: existingPayment.subscription_id, alreadyProcessed: true })
  }
  const { data: existingBookings } = await admin
    .from('bookings')
    .select('id')
    .eq('transaction_id', reference)
  if (existingBookings && existingBookings.length > 0) {
    return jsonResponse({ success: true, type: 'event_booking', ids: existingBookings.map((b) => b.id), alreadyProcessed: true })
  }

  // Re-verify with Paystack directly - never trust the client's claim that
  // the WebView flow succeeded.
  const verifyRes = await fetch(`https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`, {
    headers: { Authorization: `Bearer ${paystackSecretKey}` },
  })
  const verifyJson = await verifyRes.json().catch(() => ({}))
  const txData = verifyJson?.data
  if (!verifyRes.ok || !txData || txData.status !== 'success') {
    return jsonResponse({ error: 'Payment was not successful', paystack: verifyJson }, 402)
  }
  if (Math.abs(Number(txData.amount) - Number(intent.expected_amount_kobo)) > 1) {
    console.error('Amount mismatch on confirm:', { reference, expected: intent.expected_amount_kobo, charged: txData.amount })
    return jsonResponse({ error: 'Charged amount does not match expected price' }, 422)
  }

  const metadata = intent.metadata ?? {}

  if (intent.purchase_type === 'subscription') {
    const planId = metadata.plan_id ?? metadata.planId
    if (!planId) return jsonResponse({ error: 'Payment intent is missing plan_id' }, 500)

    const { data: plan } = await admin
      .from('subscription_plans')
      .select('price, currency, duration_days, name')
      .eq('id', planId)
      .maybeSingle()
    if (!plan) return jsonResponse({ error: 'Unknown plan' }, 500)

    const now = new Date()
    const endDate = new Date(now.getTime() + (plan.duration_days ?? 30) * 86400000)

    await admin
      .from('user_subscriptions')
      .update({ status: 'expired', updated_at: now.toISOString() })
      .eq('user_id', callerId)
      .eq('status', 'active')

    const { data: sub, error: subError } = await admin
      .from('user_subscriptions')
      .insert({
        user_id: callerId,
        plan_id: planId,
        tier: PLAN_ID_TO_TIER[planId] ?? null,
        subscription_type: plan.name ?? planId,
        billing_cycle: (plan.duration_days ?? 30) >= 365 ? 'annual' : (plan.duration_days ?? 30) >= 90 ? 'lifetime' : 'monthly',
        amount: plan.price,
        currency: plan.currency,
        status: 'active',
        payment_reference: reference,
        payment_method: 'paystack',
        start_date: now.toISOString(),
        end_date: endDate.toISOString(),
        is_auto_renew: false,
      })
      .select()
      .single()

    if (subError) {
      console.error('Failed to create subscription:', subError)
      return jsonResponse({ error: `Payment verified but subscription activation failed: ${subError.message}` }, 500)
    }

    await admin.from('subscription_payments').insert({
      user_id: callerId,
      subscription_id: sub.id,
      amount: plan.price,
      currency: plan.currency,
      payment_reference: reference,
      payment_method: 'paystack',
      payment_status: 'success',
      payment_date: now.toISOString(),
      metadata: { plan_id: planId, plan_name: plan.name },
    })

    return jsonResponse({ success: true, type: 'subscription', id: sub.id, subscription: sub })
  }

  if (intent.purchase_type === 'event_booking') {
    const eventId = metadata.event_id ?? metadata.eventId
    const selections = metadata.selected_tickets ?? metadata.selectedTickets
    if (!eventId || !Array.isArray(selections) || selections.length === 0) {
      return jsonResponse({ error: 'Payment intent is missing booking details' }, 500)
    }

    const bookingDate = metadata.selected_date ?? metadata.selectedDate ?? new Date().toISOString()
    const rows = []
    for (const sel of selections) {
      const zoneId = sel.zoneId ?? sel.zone_id
      const qty = Number(sel.quantity ?? 0)
      if (!zoneId || qty <= 0) continue
      const { data: zone } = await admin.from('zones').select('price').eq('id', zoneId).maybeSingle()
      if (!zone) continue
      rows.push({
        user_id: callerId,
        event_id: eventId,
        zone_id: zoneId,
        quantity: qty,
        amount: Number(zone.price) * qty,
        booking_date: bookingDate,
        status: 'confirmed',
        transaction_id: reference,
        payment_status: 'paid',
      })
    }

    if (rows.length === 0) {
      return jsonResponse({ error: 'No valid ticket zones in payment intent' }, 500)
    }

    const { data: bookings, error: bookingError } = await admin.from('bookings').insert(rows).select()
    if (bookingError) {
      console.error('Failed to create bookings:', bookingError)
      return jsonResponse({ error: `Payment verified but booking creation failed: ${bookingError.message}` }, 500)
    }

    return jsonResponse({ success: true, type: 'event_booking', ids: bookings.map((b) => b.id), bookings })
  }

  return jsonResponse({ error: `Unsupported purchase_type: ${intent.purchase_type}` }, 400)
})
