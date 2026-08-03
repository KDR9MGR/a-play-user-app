# Update Supabase Password Reset Email Template

**Date:** May 29, 2026
**Purpose:** Replace default Supabase password reset email with branded A-Play template

---

## Step 1: Go to Supabase Dashboard

1. Open: https://supabase.com/dashboard/project/yvnfhsipyfxdmulajbgl
2. Click **Authentication** in left sidebar
3. Click **Email Templates** tab
4. Select **"Reset Password"** template

---

## Step 2: Replace Template HTML

Copy the entire HTML code from `SUPABASE_PASSWORD_RESET_TEMPLATE.html` and paste it into the template editor.

**Important:** Make sure the template includes `{{ .ConfirmationURL }}` variable - this is replaced by Supabase with the actual reset link.

---

## Step 3: Preview and Save

1. Click **Preview** to see how it looks
2. Click **Save** to apply the template

---

## Template Features

### Visual Design:
- 🎨 Orange gradient header matching welcome email
- 🌙 Dark theme (#121212, #1E1E1E, #2A2A2A)
- ✨ A-Play branding
- 🔘 Orange "Reset Password" button

### Content:
- Personalized greeting
- Clear instructions
- Security information box with:
  - 1 hour expiration notice
  - Security tips
  - Warning about sharing link
- Alternative text link option
- Professional footer

### Supabase Variables Used:
- `{{ .ConfirmationURL }}` - The password reset link (automatically replaced by Supabase)
- `{{ .Token }}` - Available but not used in this template
- `{{ .Email }}` - Available but not used in this template

---

## Alternative: Use Supabase Variables for Personalization

If you want to personalize the greeting, you can use:

```html
<p style="color: #FFFFFF; font-size: 18px; line-height: 1.6; margin: 0 0 20px 0;">
    Hi <strong>{{ .Email }}</strong>,
</p>
```

This will show the user's email address instead of "Hi there,".

---

## Testing After Update

### Test via Dashboard:
1. Go to: Authentication → Users
2. Find a test user
3. Click ••• → Send password recovery
4. Check email inbox

### Test via cURL:
```bash
curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/auth/v1/recover' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NDUwNTgsImV4cCI6MjA2MzIyMTA1OH0.9mw2t1IKIHJkh30CdWcAfB2JhuJYdHQ_e_iHOZWcIqs' \
  -H 'Content-Type: application/json' \
  -d '{"email":"your-email@example.com"}'
```

**Expected Result:**
- Beautiful branded email in inbox
- Orange gradient header
- Dark theme matching app
- Working reset link

---

## Comparison: Before vs After

### Before (Default Supabase):
```
┌─────────────────────────────┐
│ Reset your password         │  ← Plain header
│                             │
│ Click here to reset:        │
│ [Plain blue link]           │
│                             │
│ Simple text email           │
└─────────────────────────────┘
```

### After (Branded A-Play):
```
┌─────────────────────────────────────┐
│  Reset Your Password 🔐             │  ← Orange gradient
├─────────────────────────────────────┤
│  Hi there,                          │
│                                     │
│  We received a request...           │
│                                     │
│     [Reset Password Button]         │  ← Orange gradient
│                                     │
│  Or copy this link: [link]          │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  🔒 Security Information     │  │  ← Dark card
│  │  • Expires in 1 hour         │  │
│  │  • Security tips             │  │
│  └──────────────────────────────┘  │
├─────────────────────────────────────┤
│  Need help? support@aplayworld.com  │
│  © 2026 A-Play                      │
└─────────────────────────────────────┘
```

---

## Other Email Templates (Optional)

You can also customize these templates in Supabase:

1. **Confirm Signup** - When email confirmation is enabled
2. **Magic Link** - For passwordless login
3. **Change Email Address** - When user changes email
4. **Invite User** - For admin invitations

All can use the same A-Play branding with appropriate content changes.

---

## Notes

- The template is stored in Supabase, not in your codebase
- Changes apply immediately
- You can revert to default template anytime
- Preview before saving to check formatting
- Test on different email clients (Gmail, Outlook, etc.)

---

**Status:** Template ready to copy-paste
**Next:** Update in Supabase Dashboard
**Time:** 2 minutes
