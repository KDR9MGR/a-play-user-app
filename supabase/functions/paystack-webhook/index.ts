
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'
import crypto from 'https://deno.land/std@0.168.0/node/crypto.ts';

const PAYSTACK_SECRET = Deno.env.get('PAYSTACK_SECRET_KEY')

serve(async (req) => {
  const signature = req.headers.get('x-paystack-signature')
  const body = await req.text()

  const hash = crypto.createHmac('sha512', PAYSTACK_SECRET).update(body).digest('hex')

  if (hash !== signature) {
    return new Response('Invalid signature', { status: 401 })
  }

  const event = JSON.parse(body)

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    switch (event.event) {
      case 'charge.success': {
        const email = event.data.customer.email
        const { data: user } = await supabase.from('users').select('id').eq('email', email).single()
        if (user) {
          await supabase.from('profiles').update({ is_premium: true }).eq('id', user.id)
        }
        break
      }
      case 'subscription.disable': {
        const email = event.data.customer.email
        const { data: user } = await supabase.from('users').select('id').eq('email', email).single()
        if (user) {
          await supabase.from('profiles').update({ is_premium: false }).eq('id', user.id)
        }
        break
      }
    }

    return new Response(JSON.stringify({ received: true }), { status: 200 })
  } catch (error) {
    return new Response(`Webhook Error: ${error.message}`, { status: 400 })
  }
})
