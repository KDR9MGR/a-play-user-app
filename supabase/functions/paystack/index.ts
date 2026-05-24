
// @ts-nocheck

const allowedOrigins = [
  'http://localhost:8080', // Replace with your app's actual domain
];

function getCorsHeaders(origin: string) {
  if (allowedOrigins.includes(origin)) {
    return {
      'Access-Control-Allow-Origin': origin,
      'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    };
  }
  return {
    'Access-Control-Allow-Origin': 'null',
  };
}

type JsonRecord = Record<string, unknown>

function jsonResponse(body: unknown, status = 200, origin: string) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...getCorsHeaders(origin), 'Content-Type': 'application/json' },
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
  const origin = req.headers.get('origin') || '';
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: getCorsHeaders(origin) })
  }

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405, origin)
  }

  const paystackSecretKey = Deno.env.get('PAYSTACK_SECRET_KEY')
  if (!paystackSecretKey) {
    return jsonResponse({ error: 'PAYSTACK_SECRET_KEY is not configured' }, 500, origin)
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

  try {
    if (action === 'initialize') {
      const payload = pickInitializePayload(body)
      if (!payload.email || !payload.amount || !payload.reference) {
        return jsonResponse({ error: 'email, amount, and reference are required' }, 400, origin)
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

    const upstream = await fetch(`https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${paystackSecretKey}`,
        'Content-Type': 'application/json',
      },
    })

    const upstreamJson = await upstream.json().catch(() => ({}))
    return jsonResponse(upstreamJson, upstream.status, origin)
  } catch (e) {
    return jsonResponse({ error: String(e) }, 500, origin)
  }
})
