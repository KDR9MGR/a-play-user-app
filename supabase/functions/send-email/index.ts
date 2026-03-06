
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { Resend } from 'npm:resend'

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const resend = new Resend(RESEND_API_KEY)

serve(async (req) => {
  try {
    const { to, subject, html } = await req.json()

    await resend.emails.send({
      from: 'onboarding@resend.dev',
      to,
      subject,
      html,
    })

    return new Response(JSON.stringify({ message: 'Email sent' }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(`Error: ${error.message}`, {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
