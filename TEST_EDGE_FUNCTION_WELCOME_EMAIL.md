# Test Welcome Email Edge Function

**Date:** May 29, 2026
**Status:** ✅ Edge Function deployed

---

## What Was Done

✅ **Updated `send-welcome-email` Edge Function:**
- Changed from Supabase invite system to Resend
- Added beautiful branded HTML template (orange gradient, dark theme)
- Uses `noreply@aplayworld.com` as sender
- Template matches the one in `EmailService` class

✅ **Deployed to Supabase:**
- Function: `send-welcome-email`
- Project: `yvnfhsipyfxdmulajbgl`
- Status: Deployed successfully

---

## Test the Edge Function

### Method 1: cURL Command (Quick Test)

Run this in your Mac terminal:

```bash
curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/functions/v1/send-welcome-email' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NzY0NTA1OCwiZXhwIjoyMDYzMjIxMDU4fQ.Uz2o1vLeWQy7JJ4dDEa1uJ4BSZyWhYoItmBfOmGhSoQ' \
  -H 'Content-Type: application/json' \
  -d '{"email":"godofwar.2rs@gmail.com","userName":"Abdul Razak"}'
```

**Expected Response:**
```json
{
  "message": "Welcome email sent successfully",
  "id": "some-uuid-here"
}
```

**Then check your inbox at:** `godofwar.2rs@gmail.com`

---

### Method 2: Test with Different User

```bash
curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/functions/v1/send-welcome-email' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NzY0NTA1OCwiZXhwIjoyMDYzMjIxMDU4fQ.Uz2o1vLeWQy7JJ4dDEa1uJ4BSZyWhYoItmBfOmGhSoQ' \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","userName":"Test User"}'
```

---

## What the Email Looks Like

**Subject:** Welcome to A-Play! 🎉

**From:** A-Play <noreply@aplayworld.com>

**Design:**
- 🎨 Orange gradient header (#FF6B35 to #FF8A3D)
- 🌙 Dark theme background (#121212, #1E1E1E)
- ✨ Personalized greeting: "Hi [Your Name],"
- 📋 "What's Next?" section with feature list:
  - Explore trending events in Ghana
  - Book tickets with zone-based seating
  - Connect with friends through chat
  - Share your experiences on the social feed
  - Upgrade to premium for exclusive benefits
- 🔘 Orange "Explore Events" button
- 📧 Footer with support email and copyright

---

## Troubleshooting

### Error: "RESEND_API_KEY not set"

**Fix:** Set the secret in Supabase:
```bash
supabase secrets set RESEND_API_KEY=YOUR_RESEND_API_KEY_PLACEHOLDER --project-ref yvnfhsipyfxdmulajbgl
```

### Error: "Domain not verified"

**Already Fixed:** ✅ `aplayworld.com` is verified in Resend

### Email Goes to Spam

**Fix:** DNS records already added (SPF, DKIM, DMARC) - wait 30 minutes for propagation

### Error: "Invalid API key"

**Fix:** Verify the Resend API key is correct in Supabase secrets

---

## Check Edge Function Logs

To see if the function is working:

```bash
supabase functions logs send-welcome-email --project-ref yvnfhsipyfxdmulajbgl
```

Look for:
- ✅ "Sending welcome email to: [email]"
- ✅ "Welcome email sent successfully: [id]"
- ❌ Any error messages

---

## Next Step: Update App to Use Edge Function

Currently, the app sends emails directly via Resend API in `EmailService` class.

**Option 1: Keep Current Implementation (Recommended)**
- App sends emails directly via Resend API
- Faster (no extra network hop)
- Already working

**Option 2: Update App to Use Edge Function**
- Change `EmailService.sendWelcomeEmail()` to call Edge Function
- Adds extra network hop
- More control on backend

**For now, test the Edge Function with the cURL command above!**

---

## Summary

✅ **Edge Function Updated:** Now uses Resend with beautiful template
✅ **Edge Function Deployed:** Ready to use
✅ **Ready to Test:** Run the cURL command above

**Test Command (Copy-Paste Ready):**
```bash
curl -X POST 'https://yvnfhsipyfxdmulajbgl.supabase.co/functions/v1/send-welcome-email' -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NzY0NTA1OCwiZXhwIjoyMDYzMjIxMDU4fQ.Uz2o1vLeWQy7JJ4dDEa1uJ4BSZyWhYoItmBfOmGhSoQ' -H 'Content-Type: application/json' -d '{"email":"godofwar.2rs@gmail.com","userName":"Abdul Razak"}'
```

---

**Last Updated:** May 29, 2026
**Status:** Ready to test
