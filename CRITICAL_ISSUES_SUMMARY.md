# Critical Issues Summary - June 6, 2026

**Status:** 🔴 URGENT - Auth & Subscription Issues
**Requires:** Website team + immediate action

---

## Issue 1: Password Reset Page Missing (CRITICAL) 🔴

### Problem:
- User requests password reset in mobile app
- Email sends with link to website
- Website shows **404 - Page not found**
- User cannot reset password

### Impact:
- Banned users cannot recover access
- Forgotten passwords cannot be reset
- Poor user experience

### Solution Document:
📄 **[WEBSITE_PASSWORD_RESET_IMPLEMENTATION.md](WEBSITE_PASSWORD_RESET_IMPLEMENTATION.md)**

**What Website Team Needs to Do:**
1. Create file: `/auth/reset-password/index.html`
2. Implement password reset form (HTML provided in doc)
3. Connect to Supabase (code provided)
4. Deploy to production

**Time Required:** 30 minutes
**Priority:** 🔴 URGENT

---

## Issue 2: Sandbox Account Testing Issue

### Problem:
- Sandbox test account was banned in Supabase
- After unbanning, password is incorrect
- Password reset redirects to broken website page (see Issue 1 above)

### Immediate Fix:
1. Create NEW sandbox tester account in App Store Connect:
   - Email: `aplay.test2@example.com` (use a different fake email)
   - Password: Create a new one
   - Region: Ghana

2. Sign in on device:
   - Settings → App Store → Sandbox Account
   - Use the new sandbox account

3. Test purchase again

### Full Documentation:
📄 **[SANDBOX_PURCHASE_STUCK_FIX.md](SANDBOX_PURCHASE_STUCK_FIX.md)**

---

## Issue 3: Website & Organizer App Out of Sync

### Problem:
- User app has many new features
- Website and organizer app haven't been updated
- Database schema changes not reflected

### Solution Document:
📄 **[ADMIN_ORGANIZER_SYNC_GUIDE.md](ADMIN_ORGANIZER_SYNC_GUIDE.md)**

**What This Document Contains:**
- All database schema changes
- New tables created
- New features to implement
- API endpoint updates
- UI/UX changes needed
- Migration scripts to run

**Give this to:**
- Website development team
- Organizer app development team
- Backend team (if separate)

---

## Quick Action Items

### For You (Immediate):
1. ✅ Create new sandbox tester account
2. ✅ Sign in on device with new sandbox account
3. ✅ Test subscription purchase

### For Website Team (Urgent):
1. 🔴 Implement password reset page
2. 🔴 Test password reset flow
3. 🔴 Deploy to production

### For All Teams (This Week):
1. 📘 Review ADMIN_ORGANIZER_SYNC_GUIDE.md
2. 📘 Implement database changes
3. 📘 Update features to match user app

---

## Documents to Share

### With Website Team:
1. **WEBSITE_PASSWORD_RESET_IMPLEMENTATION.md** - Password reset page (URGENT)
2. **ADMIN_ORGANIZER_SYNC_GUIDE.md** - All changes sync guide

### With Organizer App Team:
1. **ADMIN_ORGANIZER_SYNC_GUIDE.md** - All changes sync guide

### For Your Reference:
1. **SANDBOX_PURCHASE_STUCK_FIX.md** - IAP testing guide
2. **JUNE_6_2026_FIXES_COMPLETE.md** - All recent fixes
3. **POINTS_AND_REFERRALS_FIX.md** - Points system docs

---

## Priority Order

### 🔴 CRITICAL (Do Now):
1. Implement password reset page on website
2. Create new sandbox tester account for IAP testing

### 🟠 HIGH (This Week):
1. Sync website with user app changes
2. Sync organizer app with user app changes
3. Run database migrations on production

### 🟡 MEDIUM (This Month):
1. Complete all feature parity
2. Update documentation
3. Test all integration points

---

## Summary

**3 Critical Issues:**
1. ✅ Password reset page missing (doc created)
2. ✅ Sandbox account testing (doc created)
3. ✅ Website/Organizer out of sync (doc exists)

**All Documentation Ready:**
- WEBSITE_PASSWORD_RESET_IMPLEMENTATION.md (NEW)
- SANDBOX_PURCHASE_STUCK_FIX.md (NEW)
- ADMIN_ORGANIZER_SYNC_GUIDE.md (EXISTING)

**Next Steps:**
1. Share password reset doc with website team
2. Create new sandbox account for testing
3. Review sync guide for other platforms
