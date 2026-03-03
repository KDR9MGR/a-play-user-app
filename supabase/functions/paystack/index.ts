// @ts-nocheck

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

type JsonRecord = Record<string, unknown>

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

function pickInitializePayload(input: JsonRecord) {
  const payload: JsonRecord = {}
  const allowedKeys = [
    'email',
    'amount',
    'reference',
    'callback_url',
    'currency',
    'channels',
    'metadata',
  ]

  for (const key of allowedKeys) {
    if (key in input) payload[key] = input[key]
  }

  return payload
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  const paystackSecretKey = Deno.env.get('PAYSTACK_SECRET_KEY')
  if (!paystackSecretKey) {
    return jsonResponse({ error: 'PAYSTACK_SECRET_KEY is not configured' }, 500)
  }

  let body: JsonRecord
  try {
    body = (await req.json()) as JsonRecord
  } catch (_) {
    return jsonResponse({ error: 'Invalid JSON body' }, 400)
  }

  const action = body.action
  if (action !== 'initialize' && action !== 'verify') {
    return jsonResponse({ error: 'Invalid action' }, 400)
  }

  try {
    if (action === 'initialize') {
      const payload = pickInitializePayload(body)
      if (!payload.email || !payload.amount || !payload.reference) {
        return jsonResponse({ error: 'email, amount, and reference are required' }, 400)
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
      return jsonResponse(upstreamJson, upstream.status)
    }

    const reference = body.reference
    if (typeof reference !== 'string' || reference.length === 0) {
      return jsonResponse({ error: 'reference is required' }, 400)
    }

    const upstream = await fetch(`https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${paystackSecretKey}`,
        'Content-Type': 'application/json',
      },
    })

    const upstreamJson = await upstream.json().catch(() => ({}))
    return jsonResponse(upstreamJson, upstream.status)
  } catch (e) {
    return jsonResponse({ error: String(e) }, 500)
  }
})
