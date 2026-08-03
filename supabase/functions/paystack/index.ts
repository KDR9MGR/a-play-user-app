// @ts-nocheck
// Paystack initialize/verify proxy.
//
// S3 (server-side amount integrity): the client used to be trusted for the
// charge `amount` outright, so a user could pay GHS 0.01 for any booking or
// dodge the non-subscriber 2x ticket hike by sending the base amount. The
// initialize action now RECOMPUTES the expected amount server-side from live
// prices (subscription_plans / zones) and the caller's real premium status
// (from their JWT, not client-claimed metadata), and charges exactly that.
// It never raises the charge above the real price, so a correct client is
// never overcharged, and underpayment attempts are rejected. The expected
// amount is stored in payment_intents keyed by reference so the webhook can
// cross-check event.data.amount before fulfilling.
//
// S5: the '*' CORS wildcard is removed. Mobile apps don't send a standard
// Origin header so they never needed it (CORS only gates browsers); only the
// real web origins are allowed now.

import { createClient } from 'npm:@supabase/supabase-js@2'

const allowedOrigins = [
  'http://localhost:8080',
  'https://www.aplayworld.com',
  'https://aplayworld.com',
]

function getCorsHeaders(origin: string) {
  if (allowedOrigins.includes(origin)) {
    return {
      'Access-Control-Allow-Origin': origin,
      'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    }
  }
  return { 'Access-Control-Allow-Origin': 'null' }
}

type JsonRecord = Record<string, unknown>

// Temporary validation toggle: when PAYSTACK_TEST_MODE=true, charge against
// Paystack's sandbox using PAYSTACK_TEST_SECRET_KEY instead of the live key.
// Deliberately no fallback to the live key if the test key is missing while
// test mode is on - failing loudly beats silently charging real money.
function resolvePaystackSecretKey(): string | undefined {
  const testMode = (Deno.env.get('PAYSTACK_TEST_MODE') ?? '').toLowerCase() === 'true'
  return testMode ? Deno.env.get('PAYSTACK_TEST_SECRET_KEY') : Deno.env.get('PAYSTACK_SECRET_KEY')
}

function jsonResponse(body: unknown, status = 200, origin: string) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...getCorsHeaders(origin), 'Content-Type': 'application/json' },
  })
}

function pickInitializePayload(input: JsonRecord) {
  const payload: JsonRecord = {}
  const allowedKeys = ['email', 'amount', 'reference', 'callback_url', 'currency', 'channels', 'metadata']
  for (const key of allowedKeys) {
    if (key in input) payload[key] = input[key]
  }
  return payload
}

// Cedis (GHS) -> pesewas, matching the client's `(amount * 100).round()`.
function toKobo(ghs: number): number {
  return Math.round(ghs * 100)
}

/// Server-computed expected charge in kobo, or null when this purchase type
/// can't be recomputed here (then the client amount passes through unchanged
/// - a documented remaining gap, not a regression).
async function computeExpectedKobo(
  admin: ReturnType<typeof createClient>,
  callerId: string | null,
  metadata: JsonRecord,
): Promise<number | null> {
  const type = String(metadata.type ?? '')
  const planId = metadata.plan_id ?? metadata.planId

  // Subscription: the plan's own price, no premium hike.
  if (type === 'subscription' || planId) {
    if (!planId) return null
    const { data, error } = await admin
      .from('subscription_plans')
      .select('price')
      .eq('id', planId)
      .maybeSingle()
    if (error || !data || data.price == null) return null
    return toKobo(Number(data.price))
  }

  // Event tickets: sum(zone price * qty), doubled for non-premium users.
  const eventId = metadata.event_id ?? metadata.eventId
  const selections = metadata.selected_tickets ?? metadata.selectedTickets
  if (eventId && Array.isArray(selections)) {
    let base = 0
    for (const sel of selections) {
      const s = sel as JsonRecord
      const zoneId = s.zoneId ?? s.zone_id
      const qty = Number(s.quantity ?? 0)
      if (!zoneId || qty <= 0) return null
      const { data, error } = await admin
        .from('zones')
        .select('price')
        .eq('id', zoneId)
        .maybeSingle()
      if (error || !data || data.price == null) return null
      base += Number(data.price) * qty
    }

    // Premium status from the caller's own profile, never from client metadata.
    let isPremium = false
    if (callerId) {
      const { data } = await admin
        .from('profiles')
        .select('is_premium, is_subscribed')
        .eq('id', callerId)
        .maybeSingle()
      isPremium = Boolean(data?.is_premium || data?.is_subscribed)
    }
    return toKobo(isPremium ? base : base * 2)
  }

  // Restaurant / club table bookings: not recomputable from generic
  // metadata here yet - passed through (known remaining gap).
  return null
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get('origin') || ''
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: getCorsHeaders(origin) })
  }
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405, origin)
  }

  const paystackSecretKey = resolvePaystackSecretKey()
  if (!paystackSecretKey) {
    return jsonResponse({ error: 'Paystack secret key is not configured for the active mode' }, 500, origin)
  }

  let body: JsonRecord
  try {
    body = (await req.json()) as JsonRecord
  } catch (_) {
    return jsonResponse({ error: 'Invalid JSON body' }, 400, origin)
  }

  const action = body.action
  if (action !== 'initialize' && action !== 'verify') {
    return jsonResponse({ error: 'Invalid action' }, 400, origin)
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  const admin = createClient(supabaseUrl, serviceRoleKey)

  try {
    if (action === 'initialize') {
      const payload = pickInitializePayload(body)
      if (!payload.email || !payload.amount || !payload.reference) {
        return jsonResponse({ error: 'email, amount, and reference are required' }, 400, origin)
      }

      // Identify the caller from their JWT (for the premium check).
      let callerId: string | null = null
      const authHeader = req.headers.get('Authorization') ?? ''
      const jwt = authHeader.replace(/^Bearer\s+/i, '')
      if (jwt) {
        const { data } = await admin.auth.getUser(jwt)
        callerId = data?.user?.id ?? null
      }

      const metadata = (payload.metadata as JsonRecord) ?? {}
      const clientKobo = Number(payload.amount)
      const expectedKobo = await computeExpectedKobo(admin, callerId, metadata)

      if (expectedKobo != null) {
        if (clientKobo < expectedKobo - 1) {
          return jsonResponse(
            {
              error: 'Payment amount does not match the expected price for this purchase.',
              expected_amount: expectedKobo,
            },
            422,
            origin,
          )
        }
        // Charge exactly the server-computed amount: no under- or over-pay
        // relative to real prices, regardless of what the client sent.
        payload.amount = expectedKobo
      }

      // Record what we expect so the webhook can verify before fulfilling.
      try {
        await admin.from('payment_intents').upsert({
          reference: String(payload.reference),
          user_id: callerId,
          purchase_type: String(metadata.type ?? (metadata.event_id ? 'event_booking' : 'unknown')),
          expected_amount_kobo: expectedKobo ?? clientKobo,
          currency: String(payload.currency ?? 'GHS'),
          metadata,
        })
      } catch (_) {
        // Non-fatal: intent logging failure shouldn't block a correct payment.
      }

      const upstream = await fetch('https://api.paystack.co/transaction/initialize', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${paystackSecretKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      })
      const upstreamJson = await upstream.json().catch(() => ({}))
      return jsonResponse(upstreamJson, upstream.status, origin)
    }

    const reference = body.reference
    if (typeof reference !== 'string' || reference.length === 0) {
      return jsonResponse({ error: 'reference is required' }, 400, origin)
    }

    const upstream = await fetch(
      `https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`,
      {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${paystackSecretKey}`,
          'Content-Type': 'application/json',
        },
      },
    )
    const upstreamJson = await upstream.json().catch(() => ({}))
    return jsonResponse(upstreamJson, upstream.status, origin)
  } catch (e) {
    return jsonResponse({ error: String(e) }, 500, origin)
  }
})
