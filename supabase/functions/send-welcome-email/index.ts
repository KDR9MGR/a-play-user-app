
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'npm:@supabase/supabase-js@2'
import { Resend } from 'npm:resend'

// The Resend key exists ONLY here (Supabase secret) - the app bundle must
// never carry it. The recipient is always the authenticated caller's own
// address (from their JWT), never a client-supplied value, so this function
// can't be used to mail arbitrary people.
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const resend = new Resend(RESEND_API_KEY)

const jsonHeaders = { 'Content-Type': 'application/json' }

function escapeHtml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;')
}

// Beautiful welcome email template
function buildWelcomeEmailHtml(userName: string): string {
  return `<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to A-Play</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Poppins', Arial, sans-serif; background-color: #121212;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #121212;">
        <tr>
            <td align="center" style="padding: 40px 20px;">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #1E1E1E; border-radius: 16px; overflow: hidden;">
                    <!-- Header with gradient -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="color: #FFFFFF; margin: 0; font-size: 32px; font-weight: 700;">Welcome to A-Play! 🎉</h1>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <p style="color: #FFFFFF; font-size: 18px; line-height: 1.6; margin: 0 0 20px 0;">
                                Hi <strong>${userName}</strong>,
                            </p>
                            <p style="color: #B0B0B0; font-size: 16px; line-height: 1.6; margin: 0 0 20px 0;">
                                Thank you for joining A-Play - Ghana's premier event booking platform!
                            </p>
                            <p style="color: #B0B0B0; font-size: 16px; line-height: 1.6; margin: 0 0 30px 0;">
                                You're now part of a vibrant community that connects you to the best events, entertainment, and experiences across Ghana.
                            </p>

                            <!-- What's Next Section -->
                            <div style="background-color: #2A2A2A; border-radius: 12px; padding: 25px; margin: 0 0 30px 0;">
                                <h2 style="color: #FF6B35; font-size: 20px; margin: 0 0 15px 0;">What's Next?</h2>
                                <ul style="color: #B0B0B0; font-size: 15px; line-height: 1.8; margin: 0; padding-left: 20px;">
                                    <li>Explore trending events happening in Ghana</li>
                                    <li>Book tickets with zone-based seating</li>
                                    <li>Connect with friends through chat</li>
                                    <li>Share your experiences on the social feed</li>
                                    <li>Upgrade to premium for exclusive benefits</li>
                                </ul>
                            </div>

                            <!-- CTA Button -->
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="padding: 20px 0;">
                                        <a href="https://www.aplayworld.com/events" style="background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); color: #FFFFFF; padding: 16px 40px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 16px; display: inline-block;">
                                            Explore Events
                                        </a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #151515; padding: 30px; text-align: center; border-top: 1px solid #2A2A2A;">
                            <p style="color: #707070; font-size: 14px; margin: 0 0 10px 0;">
                                Need help? Contact us at <a href="mailto:support@aplayworld.com" style="color: #FF6B35; text-decoration: none;">support@aplayworld.com</a>
                            </p>
                            <p style="color: #505050; font-size: 12px; margin: 0;">
                                © 2026 A-Play. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>`;
}

serve(async (req) => {
  try {
    // Resolve the caller from their JWT. The anon key alone has no user, so
    // it is rejected here even though it passes the platform's JWT check.
    const jwt = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '')
    if (!jwt) {
      return new Response(JSON.stringify({ error: 'Missing authorization' }), {
        status: 401,
        headers: jsonHeaders,
      })
    }

    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )
    const { data: userData, error: userError } = await admin.auth.getUser(jwt)
    const email = userData?.user?.email
    if (userError || !email) {
      return new Response(JSON.stringify({ error: 'Invalid or expired session' }), {
        status: 401,
        headers: jsonHeaders,
      })
    }

    const { userName } = await req.json().catch(() => ({}))
    const name = escapeHtml(String(userName || email.split('@')[0]).slice(0, 80))

    console.log(`Sending welcome email to user ${userData.user.id}`)

    const result = await resend.emails.send({
      from: 'A-Play <noreply@aplayworld.com>',
      to: email,
      subject: 'Welcome to A-Play! 🎉',
      html: buildWelcomeEmailHtml(name),
    })

    console.log(`Welcome email sent successfully: ${result.data?.id}`)

    return new Response(JSON.stringify({
      message: 'Welcome email sent successfully',
      id: result.data?.id
    }), {
      status: 200,
      headers: jsonHeaders,
    })
  } catch (error) {
    console.error('Welcome email error:', error)
    return new Response(JSON.stringify({
      error: error.message || 'Failed to send welcome email'
    }), {
      status: 400,
      headers: jsonHeaders,
    })
  }
})
