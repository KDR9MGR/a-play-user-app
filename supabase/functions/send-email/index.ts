import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'npm:@supabase/supabase-js@2'
import { Resend } from 'npm:resend'

// The Resend key exists ONLY here (Supabase secret) - the app bundle must
// never carry it. Mail is only ever sent to the authenticated caller's own
// address (from their JWT), so this function can't be used as an open relay.
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const resend = new Resend(RESEND_API_KEY)

const jsonHeaders = { 'Content-Type': 'application/json' }

class HttpError extends Error {
  constructor(message: string, readonly status: number) {
    super(message)
  }
}

function escapeHtml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;')
}

// Template variable replacement function (values are HTML-escaped)
function renderTemplate(template: string, data: Record<string, unknown>): string {
  let rendered = template
  for (const [key, value] of Object.entries(data)) {
    const placeholder = `{{${key}}}`
    rendered = rendered.replaceAll(placeholder, escapeHtml(String(value ?? '')))
  }
  return rendered
}

// Load template from file. Names are restricted so the caller can't read
// arbitrary files via path traversal.
async function loadTemplate(templateName: string): Promise<string> {
  if (!/^[a-z0-9-]+$/.test(templateName)) {
    throw new HttpError('Invalid template name', 400)
  }
  try {
    const templatePath = `./templates/${templateName}.html`
    return await Deno.readTextFile(templatePath)
  } catch (error) {
    console.error(`Failed to load template ${templateName}:`, error)
    throw new HttpError(`Template ${templateName} not found`, 400)
  }
}

serve(async (req) => {
  try {
    // Resolve the caller from their JWT. The anon key alone has no user, so
    // it is rejected here even though it passes the platform's JWT check.
    const jwt = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '')
    if (!jwt) throw new HttpError('Missing authorization', 401)

    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )
    const { data: userData, error: userError } = await admin.auth.getUser(jwt)
    const callerEmail = userData?.user?.email
    if (userError || !callerEmail) throw new HttpError('Invalid or expired session', 401)

    const body = await req.json()
    const { to, subject, html, template, data } = body

    // The app mails the address from the caller's profile row, which can
    // differ from the auth email (e.g. after an email change) - allow either,
    // both are the caller's own.
    const { data: profile } = await admin
      .from('profiles')
      .select('email')
      .eq('id', userData.user.id)
      .maybeSingle()
    const allowed = [callerEmail, profile?.email]
      .filter((e): e is string => typeof e === 'string' && e.length > 0)
      .map((e) => e.toLowerCase())

    if (typeof to !== 'string' || !allowed.includes(to.trim().toLowerCase())) {
      throw new HttpError('Emails can only be sent to the signed-in user', 403)
    }
    if (typeof subject !== 'string' || !subject.trim()) {
      throw new HttpError('Subject is required', 400)
    }

    let emailHtml = html

    // If template is specified, load and render it
    if (template) {
      const templateContent = await loadTemplate(String(template))
      emailHtml = renderTemplate(templateContent, data || {})
    }

    if (!emailHtml) {
      throw new HttpError('Either html or template must be provided', 400)
    }

    const result = await resend.emails.send({
      from: 'A-Play <noreply@aplayworld.com>',
      to: to.trim(),
      subject: subject.slice(0, 200),
      html: emailHtml,
    })

    return new Response(JSON.stringify({
      message: 'Email sent successfully',
      id: result.data?.id
    }), {
      status: 200,
      headers: jsonHeaders,
    })
  } catch (error) {
    console.error('Email send error:', error)
    const status = error instanceof HttpError ? error.status : 400
    return new Response(JSON.stringify({
      error: error instanceof Error ? error.message : 'Failed to send email'
    }), {
      status,
      headers: jsonHeaders,
    })
  }
})
