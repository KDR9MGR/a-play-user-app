# Password Reset Implementation for APlay Website

**Date:** June 6, 2026
**Priority:** 🔴 CRITICAL
**Issue:** Password reset emails redirect to website but no reset page exists
**Impact:** Users cannot reset their passwords

---

## Problem Description

### Current Broken Flow:
1. User requests password reset in mobile app
2. Supabase sends email with reset link
3. Email link redirects to: `https://aplayworld.com/auth/reset-password?token=...`
4. ❌ **Website shows 404 - Page not found**
5. User stuck - cannot reset password

### Expected Working Flow:
1. User requests password reset
2. Supabase sends email
3. User clicks link → redirected to website
4. ✅ Website shows password reset form
5. User enters new password
6. Password updated in Supabase
7. User can login with new password

---

## What Website Needs to Implement

### 1. Create Password Reset Page

**URL:** `https://aplayworld.com/auth/reset-password`

**Required Query Parameters:**
- `token` - The password reset token from Supabase
- `type=recovery` - Indicates this is a password recovery

**Example Full URL:**
```
https://aplayworld.com/auth/reset-password?token=pkce_abc123xyz&type=recovery
```

---

### 2. Page Design Specifications

#### Layout:
```
┌─────────────────────────────────────────┐
│          [APlay Logo]                   │
│                                         │
│      Reset Your Password                │
│      ═══════════════════                │
│                                         │
│  Enter your new password below          │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ New Password                      │  │
│  │ [●●●●●●●●●●●●]          [👁]      │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ Confirm New Password              │  │
│  │ [●●●●●●●●●●●●]          [👁]      │  │
│  └───────────────────────────────────┘  │
│                                         │
│  Password requirements:                 │
│  • At least 8 characters                │
│  • Contains uppercase & lowercase       │
│  • Contains a number                    │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │   [Reset Password]                │  │
│  └───────────────────────────────────┘  │
│                                         │
│  Back to Login →                        │
└─────────────────────────────────────────┘
```

---

### 3. Required Functionality

#### A. Extract Token from URL
```javascript
// On page load
const params = new URLSearchParams(window.location.search);
const token = params.get('token');
const type = params.get('type');

// Validate
if (!token || type !== 'recovery') {
  showError('Invalid or expired reset link');
  redirectToLogin();
}
```

#### B. Verify Token with Supabase
```javascript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'YOUR_SUPABASE_URL',
  'YOUR_SUPABASE_ANON_KEY'
);

// Verify the token on page load
const { data: { session }, error } = await supabase.auth.verifyOtp({
  token_hash: token,
  type: 'recovery',
});

if (error) {
  showError('This reset link is invalid or has expired');
  return;
}
```

#### C. Password Reset Form Handler
```javascript
async function handlePasswordReset(newPassword, confirmPassword) {
  // 1. Validate passwords match
  if (newPassword !== confirmPassword) {
    showError('Passwords do not match');
    return;
  }

  // 2. Validate password strength
  if (newPassword.length < 8) {
    showError('Password must be at least 8 characters');
    return;
  }

  // 3. Update password in Supabase
  const { data, error } = await supabase.auth.updateUser({
    password: newPassword,
  });

  if (error) {
    showError('Failed to reset password: ' + error.message);
    return;
  }

  // 4. Success!
  showSuccess('Password reset successful! You can now login.');

  // 5. Redirect to login after 2 seconds
  setTimeout(() => {
    window.location.href = '/login';
  }, 2000);
}
```

---

### 4. Complete HTML/JavaScript Implementation

#### File: `/auth/reset-password.html` or `/auth/reset-password/index.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Password - APlay</title>
  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 20px;
    }

    .container {
      background: white;
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
      padding: 40px;
      max-width: 450px;
      width: 100%;
    }

    .logo {
      text-align: center;
      font-size: 32px;
      font-weight: bold;
      color: #667eea;
      margin-bottom: 10px;
    }

    h1 {
      text-align: center;
      color: #333;
      margin-bottom: 10px;
      font-size: 24px;
    }

    .subtitle {
      text-align: center;
      color: #666;
      margin-bottom: 30px;
      font-size: 14px;
    }

    .form-group {
      margin-bottom: 20px;
    }

    label {
      display: block;
      margin-bottom: 8px;
      color: #333;
      font-weight: 500;
      font-size: 14px;
    }

    .input-wrapper {
      position: relative;
    }

    input[type="password"],
    input[type="text"] {
      width: 100%;
      padding: 12px 40px 12px 12px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      font-size: 16px;
      transition: border-color 0.3s;
    }

    input:focus {
      outline: none;
      border-color: #667eea;
    }

    .toggle-password {
      position: absolute;
      right: 12px;
      top: 50%;
      transform: translateY(-50%);
      cursor: pointer;
      color: #999;
      font-size: 18px;
    }

    .requirements {
      background: #f5f5f5;
      padding: 15px;
      border-radius: 8px;
      margin-bottom: 20px;
    }

    .requirements h3 {
      font-size: 14px;
      color: #333;
      margin-bottom: 8px;
    }

    .requirements ul {
      list-style: none;
      padding: 0;
    }

    .requirements li {
      color: #666;
      font-size: 13px;
      margin-bottom: 4px;
      padding-left: 20px;
      position: relative;
    }

    .requirements li:before {
      content: '•';
      position: absolute;
      left: 0;
      color: #667eea;
    }

    .btn {
      width: 100%;
      padding: 14px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: transform 0.2s, box-shadow 0.2s;
    }

    .btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
    }

    .btn:active {
      transform: translateY(0);
    }

    .btn:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }

    .back-link {
      text-align: center;
      margin-top: 20px;
    }

    .back-link a {
      color: #667eea;
      text-decoration: none;
      font-size: 14px;
    }

    .message {
      padding: 12px;
      border-radius: 8px;
      margin-bottom: 20px;
      font-size: 14px;
    }

    .message.error {
      background: #fee;
      color: #c33;
      border: 1px solid #fcc;
    }

    .message.success {
      background: #efe;
      color: #3c3;
      border: 1px solid #cfc;
    }

    .loading {
      display: none;
      text-align: center;
      color: #666;
      margin-top: 10px;
    }

    .loading.active {
      display: block;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="logo">APlay</div>
    <h1>Reset Your Password</h1>
    <p class="subtitle">Enter your new password below</p>

    <div id="message"></div>

    <form id="resetForm">
      <div class="form-group">
        <label for="newPassword">New Password</label>
        <div class="input-wrapper">
          <input
            type="password"
            id="newPassword"
            name="newPassword"
            required
            minlength="8"
            placeholder="Enter new password"
          >
          <span class="toggle-password" onclick="togglePassword('newPassword')">👁</span>
        </div>
      </div>

      <div class="form-group">
        <label for="confirmPassword">Confirm New Password</label>
        <div class="input-wrapper">
          <input
            type="password"
            id="confirmPassword"
            name="confirmPassword"
            required
            minlength="8"
            placeholder="Confirm new password"
          >
          <span class="toggle-password" onclick="togglePassword('confirmPassword')">👁</span>
        </div>
      </div>

      <div class="requirements">
        <h3>Password Requirements:</h3>
        <ul>
          <li>At least 8 characters long</li>
          <li>Contains uppercase and lowercase letters</li>
          <li>Contains at least one number</li>
        </ul>
      </div>

      <button type="submit" class="btn" id="submitBtn">
        Reset Password
      </button>

      <div class="loading" id="loading">
        Resetting password...
      </div>
    </form>

    <div class="back-link">
      <a href="/login">← Back to Login</a>
    </div>
  </div>

  <script>
    // Initialize Supabase
    const supabase = window.supabase.createClient(
      'https://YOUR_PROJECT.supabase.co', // REPLACE WITH YOUR SUPABASE URL
      'YOUR_ANON_KEY' // REPLACE WITH YOUR SUPABASE ANON KEY
    );

    // Get token from URL
    const params = new URLSearchParams(window.location.search);
    const token = params.get('token');
    const type = params.get('type');

    // Show message helper
    function showMessage(text, isError = false) {
      const messageDiv = document.getElementById('message');
      messageDiv.className = `message ${isError ? 'error' : 'success'}`;
      messageDiv.textContent = text;
      messageDiv.style.display = 'block';
    }

    // Toggle password visibility
    function togglePassword(inputId) {
      const input = document.getElementById(inputId);
      input.type = input.type === 'password' ? 'text' : 'password';
    }

    // Validate token on page load
    async function validateToken() {
      if (!token || type !== 'recovery') {
        showMessage('Invalid or expired reset link. Please request a new one.', true);
        document.getElementById('resetForm').style.display = 'none';
        return false;
      }

      try {
        const { data, error } = await supabase.auth.verifyOtp({
          token_hash: token,
          type: 'recovery',
        });

        if (error) throw error;
        return true;
      } catch (error) {
        showMessage('This reset link has expired. Please request a new one.', true);
        document.getElementById('resetForm').style.display = 'none';
        return false;
      }
    }

    // Handle form submission
    document.getElementById('resetForm').addEventListener('submit', async (e) => {
      e.preventDefault();

      const newPassword = document.getElementById('newPassword').value;
      const confirmPassword = document.getElementById('confirmPassword').value;
      const submitBtn = document.getElementById('submitBtn');
      const loading = document.getElementById('loading');

      // Clear previous messages
      document.getElementById('message').style.display = 'none';

      // Validate passwords match
      if (newPassword !== confirmPassword) {
        showMessage('Passwords do not match', true);
        return;
      }

      // Validate password strength
      if (newPassword.length < 8) {
        showMessage('Password must be at least 8 characters long', true);
        return;
      }

      if (!/[A-Z]/.test(newPassword) || !/[a-z]/.test(newPassword)) {
        showMessage('Password must contain both uppercase and lowercase letters', true);
        return;
      }

      if (!/[0-9]/.test(newPassword)) {
        showMessage('Password must contain at least one number', true);
        return;
      }

      // Show loading
      submitBtn.disabled = true;
      loading.classList.add('active');

      try {
        // Update password
        const { data, error } = await supabase.auth.updateUser({
          password: newPassword,
        });

        if (error) throw error;

        // Success!
        showMessage('✓ Password reset successful! Redirecting to login...', false);

        // Redirect after 2 seconds
        setTimeout(() => {
          window.location.href = '/login';
        }, 2000);

      } catch (error) {
        showMessage('Failed to reset password: ' + error.message, true);
        submitBtn.disabled = false;
        loading.classList.remove('active');
      }
    });

    // Validate token when page loads
    validateToken();
  </script>
</body>
</html>
```

---

### 5. Environment Configuration

**Replace these values in the HTML file:**

```javascript
const supabase = window.supabase.createClient(
  'https://xyzcompany.supabase.co', // Your Supabase URL
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' // Your Supabase Anon Key
);
```

**Get these from:**
- Supabase Dashboard → Settings → API
- Copy "Project URL" and "anon/public" key

---

### 6. Supabase Email Template Configuration

**In Supabase Dashboard:**

1. Go to **Authentication** → **Email Templates**
2. Select **Reset Password** template
3. Ensure redirect URL is set to your website:

```
{{ .SiteURL }}/auth/reset-password?token={{ .Token }}&type=recovery
```

**Full Template Example:**
```html
<h2>Reset Your Password</h2>
<p>Someone requested a password reset for your APlay account.</p>
<p>If this was you, click the button below to reset your password:</p>
<p><a href="{{ .SiteURL }}/auth/reset-password?token={{ .Token }}&type=recovery">Reset Password</a></p>
<p>This link will expire in 1 hour.</p>
<p>If you didn't request this, you can safely ignore this email.</p>
```

---

### 7. Testing Checklist

#### Test 1: Request Password Reset
```
1. Open mobile app
2. Tap "Forgot Password"
3. Enter email
4. Check email inbox
5. ✅ Email received with reset link
```

#### Test 2: Click Reset Link
```
1. Click link in email
2. ✅ Redirects to website password reset page
3. ✅ Page loads correctly (not 404)
4. ✅ Form is displayed
```

#### Test 3: Reset Password
```
1. Enter new password
2. Confirm password
3. Click "Reset Password"
4. ✅ Success message appears
5. ✅ Redirects to login
6. ✅ Can login with new password
```

#### Test 4: Invalid Token
```
1. Use expired link (>1 hour old)
2. ✅ Shows "expired link" error
3. ✅ Form is hidden
```

#### Test 5: Password Validation
```
1. Try password < 8 characters
2. ✅ Shows validation error
3. Try passwords that don't match
4. ✅ Shows "passwords don't match" error
```

---

### 8. Security Considerations

#### ✅ Token Validation
- Token is verified with Supabase before allowing reset
- Expired tokens are rejected
- One-time use tokens (can't be reused)

#### ✅ Password Strength
- Minimum 8 characters
- Requires uppercase, lowercase, and numbers
- Client-side and server-side validation

#### ✅ HTTPS Only
- Password reset page must use HTTPS
- Prevents man-in-the-middle attacks

#### ✅ Rate Limiting
- Supabase handles rate limiting on password reset requests
- Prevents abuse

---

### 9. Mobile App Deep Link (Optional Future Enhancement)

Instead of redirecting to website, you can redirect back to mobile app:

**iOS:**
```
aplay://auth/reset-password?token=...
```

**Android:**
```
aplay://auth/reset-password?token=...
```

**This requires:**
1. Configuring deep links in mobile app
2. Creating password reset screen in app
3. Updating Supabase redirect URL

**Current solution (website) is simpler and works immediately.**

---

### 10. Deployment Steps

#### Step 1: Create the File
```bash
# On your website server
cd /path/to/website
mkdir -p auth/reset-password
```

#### Step 2: Add HTML File
```bash
# Create index.html in auth/reset-password/
nano auth/reset-password/index.html
# Paste the HTML code from section 4 above
```

#### Step 3: Update Supabase Config
```
# Replace YOUR_SUPABASE_URL and YOUR_ANON_KEY
# With actual values from Supabase Dashboard
```

#### Step 4: Configure Supabase
```
1. Supabase Dashboard → Authentication → URL Configuration
2. Site URL: https://aplayworld.com
3. Redirect URLs: Add https://aplayworld.com/auth/reset-password
```

#### Step 5: Update Email Template
```
1. Supabase Dashboard → Authentication → Email Templates
2. Select "Reset Password"
3. Update link to point to website
```

#### Step 6: Test
```
1. Request password reset from app
2. Click email link
3. Verify page loads
4. Reset password
5. Login with new password
```

---

### 11. Troubleshooting

#### Issue: 404 Not Found
**Fix:** Ensure file is at `/auth/reset-password/index.html` or configure server routing

#### Issue: CORS Error
**Fix:** Add website domain to Supabase allowed origins

#### Issue: Token Invalid
**Fix:** Check email template has correct `{{ .Token }}` variable

#### Issue: Password Not Updating
**Fix:** Verify Supabase anon key has correct permissions

---

## Summary for Website Team

**What to do:**
1. Create file: `/auth/reset-password/index.html`
2. Copy the HTML code from section 4
3. Replace Supabase URL and anon key
4. Deploy to production
5. Test the flow

**Time Required:** 30 minutes

**Priority:** 🔴 CRITICAL - Users cannot reset passwords without this

---

**Contact:** Provide this document to your website development team
