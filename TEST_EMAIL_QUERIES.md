# Manual Email Testing Queries

**Date:** May 29, 2026
**Purpose:** Test password reset and welcome emails without using the app

---

## Prerequisites

Before running these queries, you need:
1. Your user email address
2. Access to Supabase SQL Editor
3. Resend API key configured in Edge Function secrets

---

## 1. Test Welcome Email

### Option A: Call Edge Function Directly (Recommended)

**In Supabase SQL Editor, run:**

```sql
-- Replace 'your-email@example.com' with your actual email
-- Replace 'Your Name' with your actual name

SELECT
  extensions.http((
    'POST',
    current_setting('app.settings.api_url') || '/functions/v1/send-email',
    ARRAY[
      extensions.http_header('Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')),
      extensions.http_header('Content-Type', 'application/json')
    ],
    'application/json',
    json_build_object(
      'to', 'your-email@example.com',
      'subject', 'Welcome to A-Play! 🎉',
      'html',
      '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to A-Play</title>
</head>
<body style="margin: 0; padding: 0; font-family: ''Poppins'', Arial, sans-serif; background-color: #121212;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #121212;">
        <tr>
            <td align="center" style="padding: 40px 20px;">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #1E1E1E; border-radius: 16px; overflow: hidden;">
                    <tr>
                        <td style="background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="color: #FFFFFF; margin: 0; font-size: 32px; font-weight: 700;">Welcome to A-Play! 🎉</h1>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 40px 30px;">
                            <p style="color: #FFFFFF; font-size: 18px; line-height: 1.6; margin: 0 0 20px 0;">
                                Hi <strong>Your Name</strong>,
                            </p>
                            <p style="color: #B0B0B0; font-size: 16px; line-height: 1.6; margin: 0 0 20px 0;">
                                Thank you for joining A-Play - Ghana''s premier event booking platform!
                            </p>
                            <p style="color: #B0B0B0; font-size: 16px; line-height: 1.6; margin: 0 0 30px 0;">
                                You''re now part of a vibrant community that connects you to the best events, entertainment, and experiences across Ghana.
                            </p>
                            <div style="background-color: #2A2A2A; border-radius: 12px; padding: 25px; margin: 0 0 30px 0;">
                                <h2 style="color: #FF6B35; font-size: 20px; margin: 0 0 15px 0;">What''s Next?</h2>
                                <ul style="color: #B0B0B0; font-size: 15px; line-height: 1.8; margin: 0; padding-left: 20px;">
                                    <li>Explore trending events happening in Ghana</li>
                                    <li>Book tickets with zone-based seating</li>
                                    <li>Connect with friends through chat</li>
                                    <li>Share your experiences on the social feed</li>
                                    <li>Upgrade to premium for exclusive benefits</li>
                                </ul>
                            </div>
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
</html>'
    )::text
  )::extensions.http_request
) as send_email_result;
```

### Option B: Simple cURL Command (Easier)

**In your terminal, run:**

```bash
# Replace YOUR_SUPABASE_SERVICE_ROLE_KEY with your actual key
# Replace your-email@example.com with your actual email

curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/functions/v1/send-email' \
  -H 'Authorization: Bearer YOUR_SUPABASE_SERVICE_ROLE_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "to": "your-email@example.com",
    "subject": "Welcome to A-Play! 🎉",
    "html": "<h1 style=\"color: #FF6B35;\">Welcome to A-Play!</h1><p>Hi <strong>Test User</strong>,</p><p>Thank you for joining A-Play - Ghana'\''s premier event booking platform!</p><p style=\"color: #888;\">© 2026 A-Play. All rights reserved.</p>"
  }'
```

**To get your service role key:**
1. Go to Supabase Dashboard
2. Project Settings → API
3. Copy "service_role" key (not anon key)

---

## 2. Test Password Reset Email

### Option A: Trigger via Supabase Dashboard (Easiest)

1. Go to Supabase Dashboard
2. Authentication → Users
3. Find your user
4. Click three dots (•••)
5. Click "Send password recovery"
6. Check your email inbox

### Option B: Call Supabase Auth API Directly

**In your terminal, run:**

```bash
# Replace YOUR_SUPABASE_ANON_KEY with your anon key
# Replace your-email@example.com with your actual email

curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/auth/v1/recover' \
  -H 'apikey: YOUR_SUPABASE_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "your-email@example.com"
  }'
```

**Your anon key (from .env):**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NDUwNTgsImV4cCI6MjA2MzIyMTA1OH0.9mw2t1IKIHJkh30CdWcAfB2JhuJYdHQ_e_iHOZWcIqs
```

### Option C: SQL Query (Most Complex)

**In Supabase SQL Editor, run:**

```sql
-- Replace 'your-email@example.com' with your actual email

SELECT
  extensions.http((
    'POST',
    'https://yvnfhsipyfxdmulajbgl.supabase.co/auth/v1/recover',
    ARRAY[
      extensions.http_header('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NDUwNTgsImV4cCI6MjA2MzIyMTA1OH0.9mw2t1IKIHJkh30CdWcAfB2JhuJYdHQ_e_iHOZWcIqs'),
      extensions.http_header('Content-Type', 'application/json')
    ],
    'application/json',
    json_build_object('email', 'your-email@example.com')::text
  )::extensions.http_request
) as password_reset_result;
```

---

## 3. Test Custom Branded Password Reset Email (Resend)

**In your terminal, run:**

```bash
# Replace YOUR_SUPABASE_SERVICE_ROLE_KEY with your actual key
# Replace your-email@example.com with your actual email

curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/functions/v1/send-email' \
  -H 'Authorization: Bearer YOUR_SUPABASE_SERVICE_ROLE_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "to": "your-email@example.com",
    "subject": "Reset Your A-Play Password 🔐",
    "html": "<div style=\"font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #1E1E1E; border-radius: 16px; overflow: hidden;\"><div style=\"background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); padding: 40px 30px; text-align: center;\"><h1 style=\"color: #FFFFFF; margin: 0; font-size: 32px;\">Reset Your Password 🔐</h1></div><div style=\"padding: 40px 30px;\"><p style=\"color: #FFFFFF; font-size: 18px;\">Hi <strong>Test User</strong>,</p><p style=\"color: #B0B0B0; font-size: 16px;\">We received a request to reset your A-Play password. Click the button below to create a new password.</p><div style=\"text-align: center; padding: 20px 0;\"><a href=\"https://www.aplayworld.com/reset-password?token=test123\" style=\"background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); color: #FFFFFF; padding: 16px 40px; border-radius: 8px; text-decoration: none; font-weight: 600; display: inline-block;\">Reset Password</a></div><div style=\"background-color: #2A2A2A; border-left: 4px solid #FF6B35; padding: 20px; margin: 30px 0 0 0; border-radius: 8px;\"><p style=\"color: #FFA500; font-size: 14px; margin: 0;\"><strong>Security Note:</strong><br>This link will expire in 1 hour. If you didn'\''t request this, please ignore this email.</p></div></div><div style=\"background-color: #151515; padding: 30px; text-align: center; border-top: 1px solid #2A2A2A;\"><p style=\"color: #707070; font-size: 14px; margin: 0;\">Need help? Contact us at <a href=\"mailto:support@aplayworld.com\" style=\"color: #FF6B35;\">support@aplayworld.com</a></p><p style=\"color: #505050; font-size: 12px; margin: 10px 0 0 0;\">© 2026 A-Play. All rights reserved.</p></div></div>"
  }'
```

---

## 4. Verify Email Delivery

### Check Resend Dashboard

1. Log in to [Resend Dashboard](https://resend.com/emails)
2. Go to "Emails" section
3. You should see recent email sends with status:
   - ✅ **Delivered** - Email successfully sent
   - ⏳ **Queued** - Email in queue
   - ❌ **Failed** - Check error message

### Check Email Inbox

1. Check your inbox (and spam folder)
2. For password reset, you should receive **TWO emails**:
   - **Email 1:** Supabase default reset email (functional)
   - **Email 2:** Branded Resend email (beautiful design)
3. For welcome email, you should receive **ONE email**:
   - Branded Resend email with orange gradient header

---

## 5. Troubleshooting

### Email Not Received

**Check 1: Resend API Key**
```sql
-- In Supabase SQL Editor
SELECT current_setting('app.settings.api_url', true);
```

**Check 2: Edge Function Logs**
```bash
# In terminal
supabase functions logs send-email --project-ref yvnfhsipyfxdmulajbgl
```

**Check 3: Resend Domain Verification**
- Log in to Resend Dashboard
- Check if domain `aplayapp.com` is verified
- If not verified, emails only send to your email (sandbox mode)

**Check 4: Spam Folder**
- Check spam/junk folder
- Mark as "Not Spam" if found
- Add `noreply@aplayapp.com` to contacts

### cURL Command Returns Error

**Error:** `{"error":"Invalid API key"}`
**Fix:** Use service_role key, not anon key

**Error:** `{"error":"Not authenticated"}`
**Fix:** Check Bearer token format: `Bearer YOUR_KEY`

**Error:** `{"error":"Failed to send email"}`
**Fix:** Check Resend domain verification status

---

## 6. Quick Test Commands (Copy-Paste Ready)

### Test Welcome Email (Terminal)

```bash
curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/functions/v1/send-email' \
  -H 'Authorization: Bearer YOUR_SERVICE_ROLE_KEY_HERE' \
  -H 'Content-Type: application/json' \
  -d '{"to":"YOUR_EMAIL_HERE","subject":"Welcome to A-Play! 🎉","html":"<h1>Welcome!</h1><p>Test email from A-Play</p>"}'
```

### Test Password Reset (Terminal)

```bash
curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/auth/v1/recover' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NDUwNTgsImV4cCI6MjA2MzIyMTA1OH0.9mw2t1IKIHJkh30CdWcAfB2JhuJYdHQ_e_iHOZWcIqs' \
  -H 'Content-Type: application/json' \
  -d '{"email":"YOUR_EMAIL_HERE"}'
```

### Get Service Role Key

```bash
# From Supabase Dashboard:
# Project Settings → API → service_role (secret)
# DO NOT share this key publicly!
```

---

## 7. Expected Results

### Welcome Email

**Subject:** Welcome to A-Play! 🎉

**Visual:**
- Orange gradient header
- Dark theme background (#1E1E1E)
- Personalized greeting
- Feature highlights in dark card
- Orange CTA button
- Footer with support email

**Delivery Time:** Usually within 30 seconds

### Password Reset Email

**From Supabase (Email 1):**
- Subject: Reset Your Password
- Plain Supabase template
- Magic link to reset password
- Expires in 1 hour

**From Resend (Email 2):**
- Subject: Reset Your A-Play Password 🔐
- Orange gradient header
- Branded design matching app
- Security warning box
- Footer with support email

**Delivery Time:** Usually within 30 seconds

---

## 8. Production Checklist

Before going live:

- [ ] Verify Resend domain `aplayapp.com` is verified
- [ ] Test welcome email with real user email
- [ ] Test password reset with real user email
- [ ] Check both emails arrive in inbox (not spam)
- [ ] Verify all links work correctly
- [ ] Test on multiple email clients (Gmail, Outlook, etc.)
- [ ] Verify email deliverability rates in Resend Dashboard
- [ ] Set up SPF/DKIM/DMARC records for domain

---

**Last Updated:** May 29, 2026
**Status:** Ready for testing
