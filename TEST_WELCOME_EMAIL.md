# Test Welcome Email - Quick Guide

**Date:** May 29, 2026
**Status:** Ready to test

---

## The Welcome Email System

Your app sends welcome emails **directly via Resend API** (not through Supabase Edge Functions).

**How it works:**
1. User signs up in app
2. `EmailService().sendWelcomeEmail()` is called
3. Email is sent via Resend API from Flutter app
4. Template is in: `lib/core/services/email_service.dart` lines 156-233

---

## Test Method 1: Direct Resend API (Easiest)

Run this command in your Mac terminal:

```bash
curl -X POST 'https://api.resend.com/emails' \
  -H 'Authorization: Bearer YOUR_RESEND_API_KEY_PLACEHOLDER' \
  -H 'Content-Type: application/json' \
  -d '{
    "from": "A-Play <noreply@aplayworld.com>",
    "to": "godofwar.2rs@gmail.com",
    "subject": "Welcome to A-Play! 🎉",
    "html": "<div style=\"font-family: Arial; background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); padding: 40px; text-align: center; border-radius: 16px; color: white;\"><h1 style=\"margin: 0;\">Welcome to A-Play! 🎉</h1><p style=\"font-size: 18px;\">Hi Test User,</p><p>Thank you for joining Ghana'\''s premier event booking platform!</p><div style=\"background: rgba(0,0,0,0.2); padding: 20px; border-radius: 8px; margin: 20px 0;\"><h3>What'\''s Next?</h3><ul style=\"text-align: left; display: inline-block;\"><li>Explore trending events in Ghana</li><li>Book tickets with zone-based seating</li><li>Connect with friends</li><li>Share your experiences</li><li>Upgrade to premium</li></ul></div><p style=\"font-size: 14px; color: #f0f0f0;\">© 2026 A-Play. All rights reserved.</p></div>"
  }'
```

**Expected Response:**
```json
{
  "id": "some-uuid-here"
}
```

**Then check your inbox at:** godofwar.2rs@gmail.com

---

## Test Method 2: Via App Signup (Full Integration Test)

### Steps:

1. **Run the app** (from Windows terminal):
   ```bash
   flutter run
   ```

2. **Navigate to Sign Up screen**

3. **Create a new test account:**
   - Email: Use a **different email** (not one already registered)
   - Password: Any password
   - Name: Test User

4. **Complete signup**

5. **Check email inbox** for welcome email

6. **Check console logs** for:
   ```
   ✅ "Email sent successfully to [email]"
   ```
   Or if failed:
   ```
   ❌ "Failed to send welcome email: [error]"
   ```

---

## Test Method 3: Check Resend Dashboard

1. **Log in to Resend Dashboard:** https://resend.com/emails

2. **View recent emails:**
   - You should see welcome email sends
   - Status: Delivered / Queued / Failed

3. **Check delivery status:**
   - ✅ **Delivered** = Email successfully sent
   - ⏳ **Queued** = Email in queue
   - ❌ **Failed** = Check error message

---

## Troubleshooting

### Issue: "Resend API key not configured"

**Fix:** Already configured in `.env`:
```env
RESEND_API_KEY=YOUR_RESEND_API_KEY_PLACEHOLDER
```

### Issue: "Domain not verified"

**Fix:** Already verified - `aplayworld.com` is verified in Resend ✅

### Issue: Email goes to spam

**Fix:** DNS records added (SPF, DKIM, DMARC) - wait 30 minutes for propagation

### Issue: Email not received

**Checks:**
1. Check spam folder
2. Check Resend Dashboard for delivery status
3. Verify email address is correct
4. Check API key is valid (run cURL test above)

---

## What the Welcome Email Looks Like

**Subject:** Welcome to A-Play! 🎉

**Visual:**
- Orange gradient header (#FF6B35 to #FF8A3D)
- Dark theme background
- Personalized greeting: "Hi [Username],"
- "What's Next?" section with feature list
- Footer with support email and copyright

**From:** A-Play <noreply@aplayworld.com>

**To:** User's signup email

---

## Expected Results

### After running cURL command:

```json
{
  "id": "abc123-def456-789"
}
```

### In your email inbox:

- **Subject:** Welcome to A-Play! 🎉
- **From:** A-Play <noreply@aplayworld.com>
- **Design:** Orange gradient header, dark card with feature list
- **Location:** Inbox (not spam, after DNS propagates)

---

## Summary

✅ **Welcome email system is fully implemented**
✅ **Domain is verified**
✅ **DNS records are configured**
✅ **Just needs testing**

**Test now with the cURL command above!**

---

**Last Updated:** May 29, 2026
**Status:** Ready to test
