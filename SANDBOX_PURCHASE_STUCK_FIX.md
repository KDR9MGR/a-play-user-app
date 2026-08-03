# Sandbox Purchase Stuck at "Pending" - Fix Guide

**Date:** June 6, 2026
**Issue:** Purchase stuck at `PurchaseStatus.pending` in sandbox
**Status:** TROUBLESHOOTING

---

## Problem

Purchase flow stops at:
```
IAPService: ⏳ Purchase PENDING
IAPService: → Product: 7day
IAPService: → Purchase ID: null
IAPService: → Transaction Date: null
IAPService: → Pending Complete: false
```

---

## Root Causes (In Order of Likelihood)

### 1. ⚠️ NOT USING SANDBOX TEST ACCOUNT (90% of cases)

**Problem:** You're trying to test IAP without signing in to a sandbox account

**Fix:**

#### On Real Device:
1. Open **Settings** app
2. Scroll to **App Store**
3. Tap **Sandbox Account** (at the very bottom)
4. Sign in with your sandbox test account

#### On Simulator:
1. Open **Settings** app
2. Scroll to **App Store**
3. Tap **Sandbox Account**
4. Sign in with sandbox account

**⚠️ IMPORTANT:**
- Do NOT use your real Apple ID
- Must use a sandbox tester account created in App Store Connect

---

### 2. 🔑 NO SANDBOX TEST ACCOUNT CREATED

**Problem:** You haven't created a sandbox tester in App Store Connect

**Fix:**

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **Users and Access**
3. Click **Sandbox Testers** tab
4. Click **+** (Add Tester)
5. Fill in details:
   - **Email:** Use a FAKE email (doesn't need to exist)
     - Good: `aplay.tester1@example.com`
     - Good: `test.user@sandboxtest.com`
     - Bad: Your real email
   - **Password:** Create a secure password
   - **First Name:** Test
   - **Last Name:** User
   - **Region:** Ghana or United States
6. Click **Save**
7. **No email verification needed** - it's fake!

---

### 3. 📱 WRONG SETTINGS LOCATION

**Common Mistake:** Looking in the wrong place

**Correct Location:**
```
Settings
  └─ App Store
      └─ Sandbox Account  ← SIGN IN HERE
```

**NOT:**
```
Settings
  └─ [Your Name] (Apple ID)  ← DON'T USE THIS
```

---

### 4. 🌐 NETWORK CONNECTIVITY

**Problem:** Poor connection to Apple's sandbox servers

**Fix:**
- Ensure device has internet connection
- Try switching between WiFi and cellular
- Restart device

---

### 5. 🔄 STALE PURCHASE STATE

**Problem:** Previous purchase attempt still cached

**Fix:**

#### Quick Restart:
```bash
# Kill app completely
# Relaunch
flutter run
```

#### Force Clear (if restart doesn't work):
1. Delete app from device
2. Run `flutter clean`
3. Reinstall: `flutter run`
4. Sign in to sandbox account again
5. Try purchase again

---

### 6. ⏰ SANDBOX SERVER DELAYS

**Problem:** Apple's sandbox is just slow

**Normal Behavior:**
- Sandbox can take 10-60 seconds to process
- Much slower than production
- Sometimes requires multiple attempts

**Fix:** Wait longer (up to 2 minutes)

---

## Step-by-Step Troubleshooting

### Step 1: Verify Sandbox Account Setup

**Check in App Store Connect:**
```
1. Go to appstoreconnect.apple.com
2. Users and Access → Sandbox Testers
3. ✅ Verify tester exists
4. ✅ Note the email and password
```

### Step 2: Sign In to Sandbox Account on Device

**On your test device:**
```
1. Open Settings
2. Scroll to "App Store"
3. Tap "Sandbox Account"
4. IF already signed in:
   - Tap the email
   - Sign Out
5. Sign in with sandbox tester email/password
6. ✅ You should see "Sandbox: email@example.com"
```

### Step 3: Verify App Store Products

**Check products are configured:**
```
1. App Store Connect → Your App
2. Features → In-App Purchases
3. ✅ Verify 4 products exist:
   - 7day (Weekly)
   - 1month (Monthly)
   - 3SUB (Quarterly)
   - 365day (Annual)
4. ✅ Status = "Ready to Submit" or "Approved"
```

### Step 4: Test Purchase Again

**In your app:**
```
1. Force close app
2. Relaunch app
3. Navigate to subscription screen
4. Tap "Subscribe Now" on any plan
5. Watch console for logs
```

**Expected Flow:**
```
IAPService: ✓ Purchase initiated
IAPService: Waiting for user to confirm payment...

[Apple dialog appears: "Confirm Your In-App Purchase"]
[Tap "Buy" button]

IAPService: ⏳ Purchase PENDING
[Wait 5-30 seconds]

IAPService: ✓ Purchase SUCCESSFUL!
```

**If Still Stuck:**
```
IAPService: ⏳ Purchase PENDING
[No change after 2 minutes]
→ See Fix #5 below
```

---

## Quick Fixes

### Fix #1: Sign Out and Back In
```
Settings → App Store → Sandbox Account
1. Tap email → Sign Out
2. Wait 5 seconds
3. Sign in again
4. Try purchase
```

### Fix #2: Restart Everything
```bash
# 1. Force quit app
# 2. Restart device
# 3. Open Settings → App Store → Verify sandbox account
# 4. Relaunch app
flutter run
```

### Fix #3: Delete and Reinstall
```bash
# 1. Delete app from device
# 2. Clean Flutter
flutter clean
flutter pub get

# 3. Rebuild
flutter run

# 4. Sign in to sandbox (Settings → App Store)
# 5. Try purchase
```

### Fix #4: Use Different Sandbox Account
```
1. Create a NEW sandbox tester in App Store Connect
2. Sign out of current sandbox account
3. Sign in with new account
4. Try purchase
```

### Fix #5: Clear Stuck Purchase
```bash
# If purchase is permanently stuck:

# 1. Force quit app
# 2. On device: Settings → App Store → Sandbox Account → Sign Out
# 3. Delete app
# 4. Clean build
flutter clean && flutter pub get && flutter run

# 5. Sign in to sandbox
# 6. Try purchase with DIFFERENT product (not 7day)
```

---

## Debugging Console Logs

### ✅ Successful Flow
```
IAPService: ✓ Purchase initiated
IAPService: Waiting for user to confirm payment...
IAPService: ⏳ Purchase PENDING
[5-30 seconds delay]
IAPService: ✓ Purchase SUCCESSFUL!
IAPService: Product: 7day
IAPService: Transaction: 1000000...
```

### ❌ Stuck Flow (Your Current Issue)
```
IAPService: ✓ Purchase initiated
IAPService: Waiting for user to confirm payment...
IAPService: ⏳ Purchase PENDING
IAPService: → Purchase ID: null          ← STUCK HERE
IAPService: → Transaction Date: null
[Never progresses beyond this point]
```

**Meaning:**
- `Purchase ID: null` = Apple hasn't processed the purchase yet
- `Transaction Date: null` = No transaction created
- Usually means: **Not signed in to sandbox account**

### ✅ Sandbox Account Signed In (Expected)
When you tap "Subscribe Now", Apple dialog should show:
```
┌─────────────────────────────────────┐
│ Confirm Your In-App Purchase        │
│                                      │
│ 7 Day Fun                            │
│ $3.99                                │
│                                      │
│ [Environment: Sandbox]               │ ← SHOULD SEE THIS
│                                      │
│ [Cancel]              [Buy]          │
└─────────────────────────────────────┘
```

### ❌ NOT Signed In (Problem)
Dialog will show error or won't appear at all.

---

## Testing Checklist

### Before Purchase:
- [ ] Sandbox tester created in App Store Connect
- [ ] Signed in to sandbox account (Settings → App Store → Sandbox Account)
- [ ] Verified sandbox email shows in Settings
- [ ] App has internet connection
- [ ] IAP products loaded (console shows "Found 4 products")

### During Purchase:
- [ ] Apple dialog appears
- [ ] Dialog shows "[Environment: Sandbox]"
- [ ] Can see product price
- [ ] Tap "Buy" button

### After Purchase:
- [ ] Console shows "Purchase PENDING"
- [ ] Wait up to 60 seconds
- [ ] Console should show "Purchase SUCCESSFUL"
- [ ] Success screen appears

---

## Common Mistakes

### ❌ Mistake 1: Using Real Apple ID
**Wrong:** Signing in with your actual Apple ID
**Right:** Sign in with sandbox tester (fake email)

### ❌ Mistake 2: Wrong Settings Location
**Wrong:** Settings → [Your Name] → Sign Out
**Right:** Settings → App Store → Sandbox Account

### ❌ Mistake 3: Expecting Real Email
**Wrong:** Creating sandbox account with your real email
**Right:** Use completely fake email: `test@example.com`

### ❌ Mistake 4: Not Waiting Long Enough
**Wrong:** Canceling after 10 seconds
**Right:** Wait up to 2 minutes for sandbox

### ❌ Mistake 5: Testing in Production
**Wrong:** Trying to use production App Store
**Right:** Must use sandbox for testing

---

## Advanced Debugging

### Check StoreKit Configuration
```bash
# iOS Console (Xcode → Window → Devices and Simulators → View Device Logs)
# Look for errors like:
- "Invalid Product Identifier"
- "Cannot connect to iTunes Store"
- "User not signed in to sandbox"
```

### Verify Product IDs Match
**In Code:**
```dart
static const String weeklyProduct = '7day';  // Must match App Store Connect
```

**In App Store Connect:**
```
Product ID: 7day  ✅ MATCH
```

**If Mismatch:**
- App won't find the product
- Purchase will fail immediately

---

## If Nothing Works

### Last Resort Steps:

1. **Create Brand New Sandbox Account**
   - Different email
   - Different region

2. **Delete Everything**
   ```bash
   # Remove app
   # Clean Flutter
   flutter clean
   # Remove build folder
   rm -rf ios/build
   rm -rf build
   # Reinstall
   flutter pub get
   flutter run
   ```

3. **Test on Different Device**
   - Physical device instead of simulator
   - Or vice versa

4. **Wait 24 Hours**
   - Sometimes Apple's sandbox has issues
   - Try again tomorrow

---

## Production vs Sandbox Differences

| Aspect | Sandbox | Production |
|--------|---------|------------|
| **Speed** | Slow (10-60s) | Fast (1-5s) |
| **Account** | Fake email | Real Apple ID |
| **Payment** | No real charge | Real charge |
| **Reliability** | Can be flaky | Very reliable |
| **Setup** | Settings → App Store | Automatic |

---

## Quick Reference

### Create Sandbox Tester
```
App Store Connect → Users and Access → Sandbox Testers → +
Email: test1@example.com
Password: YourPassword123
Region: Ghana
```

### Sign In to Sandbox
```
Device Settings → App Store → Sandbox Account
Sign in with: test1@example.com
```

### Verify Signed In
```
Settings → App Store
Should see: "Sandbox: test1@example.com"
```

### Test Purchase
```
1. Open app
2. Go to subscriptions
3. Tap "Subscribe Now"
4. Apple dialog appears with "[Environment: Sandbox]"
5. Tap "Buy"
6. Wait 10-60 seconds
7. Success!
```

---

## Summary

**Most Likely Fix:**
1. Create sandbox tester in App Store Connect
2. Sign in to sandbox in Settings → App Store → Sandbox Account
3. Try purchase again

**If That Doesn't Work:**
- Restart app
- Restart device
- Delete and reinstall app
- Wait longer (up to 2 minutes)

**Console Should Show:**
```
IAPService: ✓ Purchase initiated
IAPService: ⏳ Purchase PENDING
[Wait...]
IAPService: ✓ Purchase SUCCESSFUL!
```

---

**Status:** Follow these steps and the purchase should complete!
