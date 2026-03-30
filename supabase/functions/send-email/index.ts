
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { Resend } from 'npm:resend'

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const resend = new Resend(RESEND_API_KEY)

// Template variable replacement function
function renderTemplate(template: string, data: Record<string, any>): string {
  let rendered = template
  for (const [key, value] of Object.entries(data)) {
    const placeholder = `{{${key}}}`
    rendered = rendered.replaceAll(placeholder, String(value || ''))
  }
  return rendered
}

// Load template from file
async function loadTemplate(templateName: string): Promise<string> {
  try {
    const templatePath = `./templates/${templateName}.html`
    return await Deno.readTextFile(templatePath)
  } catch (error) {
    console.error(`Failed to load template ${templateName}:`, error)
    throw new Error(`Template ${templateName} not found`)
  }
}

serve(async (req) => {
  try {
    const body = await req.json()
    const { to, subject, html, template, data } = body

    let emailHtml = html

    // If template is specified, load and render it
    if (template) {
      const templateContent = await loadTemplate(template)
      emailHtml = renderTemplate(templateContent, data || {})
    }

    if (!emailHtml) {
      throw new Error('Either html or template must be provided')
    }

    const result = await resend.emails.send({
      from: 'A-Play <bookings@resend.dev>',
      to,
      subject,
      html: emailHtml,
    })

    return new Response(JSON.stringify({
      message: 'Email sent successfully',
      id: result.data?.id
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('Email send error:', error)
    return new Response(JSON.stringify({
      error: error.message || 'Failed to send email'
    }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
