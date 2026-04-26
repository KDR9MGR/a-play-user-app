# A-Play iOS Subscription System - MVP Production Readiness Summary

**Date**: April 24, 2026
**Version**: 3.0.0+1
**Status**: ⚠️ **NOT READY FOR PRODUCTION** - Critical fixes required
**Completion**: 60%

---

## Executive Summary

The iOS In-App Purchase subscription system has been successfully implemented with core functionality working as expected. Purchase flow, database integration, and user interface are operational. However, **10 critical issues** must be resolved before production deployment.

### ✅ What's Working (MVP Core Features)

1. **Complete Purchase Flow**
   - StoreKit integration working
   - Products loading correctly (4 subscription tiers)
   - Purchase transactions completing successfully
   - Receipt verification integrated (with sandbox limitations)
   - Database records created automatically

2. **User-Specific Subscriptions**
   - Proper authentication checks
   - User ID filtering on all queries
   - No hardcoded user data
   - Different users see different subscriptions

3. **Subscription Management UI**
   - "Active Subscription" screen with details
   - Three management buttons:
     - Change Plan (guides to iOS Settings)
     - Manage in iOS Settings (opens App Store)
     - Cancel Subscription (confirmation dialog)
   - Subscription details card (plan, tier, days remaining, renewal date)
   - Manual refresh button to sync StoreKit state

4. **Database Integration**
   - Automatic profile updates via triggers
   - Subscription status tracking
   - Transaction history
   - Tier points system
   - RLS policies for security

5. **StoreKit Sync**
   - Automatic cancellation detection
   - Restore purchases on app reinstall
   - Database/StoreKit state synchronization
   - Transaction completion handling

6. **Product Tiers**
   - **Gold Tier**: 7day plan ($3.99/week)
   - **Platinum Tier**: 1month plan ($12.99/month) & 3SUB plan ($36.99/quarter)
   - **Black Tier**: 365day plan ($146.99/year)

---

## ⚠️ CRITICAL Issues - Must Fix Before Production

### 1. Missing In-App Purchase Entitlement
**File**: `ios/Runner/RunnerRelease.entitlements`

**Problem**: App cannot process real purchases without IAP entitlement

**Fix Required**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.in-app-payments</key>
    <array/>
    <key>aps-environment</key>
    <string>production</string>
</dict>
</plist>
```

**Impact**: ❌ App Store will reject app without this
**Estimated Time**: 5 minutes

---

### 2. Edge Function Table Mismatch
**File**: `supabase/functions/verify-apple-sub/index.ts`

**Problem**: Edge function writes to wrong table
- Current: `subscriptions` table
- Required: `user_subscriptions` table

**Fix Required** (Line 182 and 201):
```typescript
// Change from:
await supabase.from('subscriptions').upsert(...)
// To:
await supabase.from('user_subscriptions').upsert(...)
```

**Impact**: ❌ Receipt verification will fail in production
**Estimated Time**: 15 minutes

---

### 3. Hardcoded Subscription Prices
**File**: `lib/features/subscription/service/iap_verification_service.dart`

**Problem**: Prices hardcoded in code instead of from StoreKit

**Fix Required** (Lines 185-197):
```dart
// Remove _getAmount() method entirely
// Use product.rawPrice from StoreKit ProductDetails instead

// In verifyAndActivateSubscription():
final product = await _getProductDetails(productId);
final amount = product?.rawPrice ?? 0.0;
```

**Impact**: ⚠️ Price changes in App Store Connect won't reflect in database
**Estimated Time**: 30 minutes

---

### 4. Missing Subscription Expiry Cron Job
**Location**: Supabase Dashboard → Database → Cron Jobs

**Problem**: Expired subscriptions won't be marked automatically

**Fix Required**:
```sql
-- Run in Supabase SQL Editor
SELECT cron.schedule(
  'expire-old-subscriptions',
  '0 2 * * *', -- Daily at 2 AM UTC
  $$SELECT expire_old_subscriptions()$$
);
```

**Impact**: ❌ Users will keep access after subscription expires
**Estimated Time**: 5 minutes

---

### 5. RLS Policy Conflicts
**Location**: Supabase Dashboard → Database → Policies

**Problem**: Two conflicting INSERT policies may exist

**Fix Required**:
```sql
-- Verify only correct policy exists
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'user_subscriptions' AND cmd = 'INSERT';

-- Should return ONLY:
-- user_subscriptions_insert_own | INSERT | auth.uid() = user_id
-- user_subscriptions_insert_service_role | INSERT | true (for service_role)

-- If 'user_subscriptions_insert_service' exists with "WITH CHECK (false)", drop it:
DROP POLICY IF EXISTS "user_subscriptions_insert_service" ON user_subscriptions;
```

**Impact**: ❌ Users may be unable to purchase subscriptions
**Estimated Time**: 10 minutes

---

### 6. Missing APPLE_SHARED_SECRET Configuration
**File**: `.env` and Supabase Edge Function secrets

**Problem**: Edge function needs App-Specific Shared Secret for receipt validation

**Fix Required**:
1. Go to App Store Connect → App → General → App Information
2. Copy "App-Specific Shared Secret"
3. Add to Supabase Edge Function secrets:
   ```bash
   supabase secrets set APPLE_SHARED_SECRET=your_secret_here
   ```
4. Document in `.env.example`:
   ```bash
   # Apple IAP Receipt Verification
   APPLE_SHARED_SECRET=get_from_app_store_connect
   ```

**Impact**: ⚠️ Receipt verification will fail (though local DB verification still works)
**Estimated Time**: 10 minutes

---

### 7. Production vs Sandbox Environment Configuration
**Problem**: No separation between sandbox and production receipt endpoints

**Fix Required**: Create environment-based configuration
```dart
// lib/core/config/environment.dart
class Environment {
  static const String appleVerificationUrl = String.fromEnvironment(
    'APPLE_VERIFICATION_URL',
    defaultValue: 'https://sandbox.itunes.apple.com/verifyReceipt', // Sandbox
  );

  static bool get isProduction =>
    const bool.fromEnvironment('PRODUCTION', defaultValue: false);
}

// Build commands:
// Sandbox: flutter build ios --release --dart-define=PRODUCTION=false
// Production: flutter build ios --release --dart-define=PRODUCTION=true --dart-define=APPLE_VERIFICATION_URL=https://buy.itunes.apple.com/verifyReceipt
```

**Impact**: ⚠️ Production receipts will be sent to sandbox endpoint
**Estimated Time**: 1 hour

---

### 8. Dual IAP Service Implementation
**Files**:
- `lib/core/services/iap_service.dart` (newer, cleaner)
- `lib/core/services/purchase_manager.dart` (legacy)

**Problem**: Two services doing similar things cause confusion

**Fix Required**:
1. Migrate any missing features from PurchaseManager to IAPService
2. Update all references to use IAPService
3. Delete or deprecate PurchaseManager

**Impact**: ⚠️ Maintenance burden and potential bugs
**Estimated Time**: 2 hours

---

### 9. Missing Unique Constraint on Active Subscriptions
**Location**: Supabase Database

**Problem**: User could have multiple active subscriptions simultaneously

**Fix Required**:
```sql
-- Add partial unique index
CREATE UNIQUE INDEX idx_user_one_active_subscription
ON user_subscriptions (user_id)
WHERE status = 'active';
```

**Impact**: ⚠️ Data integrity issues
**Estimated Time**: 5 minutes

---

### 10. App Store Connect Product Configuration
**Location**: App Store Connect → In-App Purchases

**Requirements to Verify**:
- [ ] All 4 products created with correct IDs:
  - `7day` - $3.99/week
  - `1month` - $12.99/month
  - `3SUB` - $36.99/quarter (3 months)
  - `365day` - $146.99/year
- [ ] Products added to subscription group
- [ ] Pricing set for all territories
- [ ] Localized descriptions provided
- [ ] Tax category selected
- [ ] Products submitted for review

**Impact**: ❌ App cannot be submitted without this
**Estimated Time**: 1-2 hours

---

## 🔧 Moderate Priority Fixes

### 1. Add Restore Purchases UI
**File**: `lib/features/subscription/view/subscription_screen_new.dart`

Add button to restore purchases for users switching devices:
```dart
TextButton.icon(
  onPressed: () async {
    await _iapService.restorePurchases();
    await _refreshSubscriptionStatus();
  },
  icon: Icon(Icons.restore),
  label: Text('Restore Purchases'),
)
```

**Impact**: Better user experience
**Estimated Time**: 30 minutes

---

### 2. Improve Error Messages
Add error codes to user-facing messages for better support:
```dart
_errorMessage = 'Verification failed (Error: ${e.code}). Please contact support.';
```

**Impact**: Easier customer support
**Estimated Time**: 30 minutes

---

### 3. Add Retry Logic for Network Failures
Implement exponential backoff for failed verification attempts:
```dart
Future<void> _retryWithBackoff(Function action, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await action();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: pow(2, i).toInt()));
    }
  }
}
```

**Impact**: Better reliability
**Estimated Time**: 1 hour

---

### 4. Create Constants File
Consolidate all hardcoded product mappings:
```dart
// lib/features/subscription/constants/subscription_constants.dart
class SubscriptionConstants {
  static const productIds = ['7day', '1month', '3SUB', '365day'];

  static const productToPlanId = {
    '7day': 'weekly_plan',
    '1month': 'monthly_plan',
    '3SUB': 'quarterly_plan',
    '365day': 'annual_plan',
  };

  static const productToTier = {
    '7day': 'Gold',
    '1month': 'Platinum',
    '3SUB': 'Platinum',
    '365day': 'Black',
  };

  static const productToDuration = {
    '7day': Duration(days: 7),
    '1month': Duration(days: 30),
    '3SUB': Duration(days: 90),
    '365day': Duration(days: 365),
  };
}
```

**Impact**: Better maintainability
**Estimated Time**: 1 hour

---

### 5. Add Analytics Tracking
Track subscription events for business intelligence:
```dart
// On purchase success
await analytics.logEvent(
  name: 'subscription_purchased',
  parameters: {
    'product_id': productId,
    'tier': tier,
    'price': amount,
  },
);

// On cancellation
await analytics.logEvent(
  name: 'subscription_cancelled',
  parameters: {
    'product_id': productId,
    'days_active': daysActive,
  },
);
```

**Impact**: Business insights
**Estimated Time**: 2 hours

---

## 📋 Pre-Launch Checklist

### Code & Configuration
- [ ] Fix all 10 critical issues above
- [ ] Run `flutter analyze` - 0 errors
- [ ] Run `flutter test` - all tests pass
- [ ] Update version number in `pubspec.yaml`
- [ ] Create release notes
- [ ] Tag release in git: `git tag v3.0.0`

### App Store Connect
- [ ] Create all 4 subscription products
- [ ] Configure subscription group
- [ ] Set pricing for all territories
- [ ] Provide localized descriptions
- [ ] Submit products for review
- [ ] Configure tax categories
- [ ] Set up promotional offers (if applicable)

### Supabase Configuration
- [ ] Apply all database migrations
- [ ] Set up cron job for subscription expiry
- [ ] Verify RLS policies
- [ ] Add APPLE_SHARED_SECRET to secrets
- [ ] Test Edge Function with production receipt
- [ ] Set up database backups
- [ ] Configure monitoring/alerts

### iOS Configuration
- [ ] Add IAP entitlement to RunnerRelease.entitlements
- [ ] Change APS environment to 'production'
- [ ] Add API key restrictions in Google Cloud Console
- [ ] Verify bundle ID matches App Store Connect
- [ ] Test on physical device
- [ ] Test in TestFlight with real subscription

### Testing
- [ ] Test complete purchase flow (sandbox)
- [ ] Test purchase flow in TestFlight (production sandbox)
- [ ] Test subscription renewal (accelerated in sandbox)
- [ ] Test subscription cancellation
- [ ] Test restore purchases
- [ ] Test on multiple devices
- [ ] Test with different user accounts
- [ ] Test network failure scenarios
- [ ] Verify database updates correctly
- [ ] Verify profile tier updates

### Documentation
- [ ] Create user-facing subscription FAQ
- [ ] Document support process for subscription issues
- [ ] Create internal runbook for common issues
- [ ] Document environment variables
- [ ] Update README with subscription setup

### Security
- [ ] Rotate all API keys
- [ ] Verify .env not in git repository
- [ ] Review RLS policies with security team
- [ ] Test unauthorized access attempts
- [ ] Verify receipt validation is secure

---

## 🚀 Production Deployment Steps

### Phase 1: Prepare (1-2 days)
1. Fix all 10 critical issues
2. Complete App Store Connect setup
3. Apply database migrations
4. Set up cron jobs and secrets

### Phase 2: TestFlight (3-5 days)
1. Build with production configuration
2. Upload to TestFlight
3. Test with internal team
4. Test with external beta testers
5. Fix any issues found

### Phase 3: App Review (1-2 weeks)
1. Submit to App Store Review
2. Respond to any reviewer questions
3. Fix any issues identified
4. Get approval

### Phase 4: Launch (1 day)
1. Release to App Store
2. Monitor error logs
3. Monitor subscription metrics
4. Have support team ready
5. Announce launch

---

## 📊 Success Metrics

### Technical Metrics
- Purchase success rate > 95%
- Receipt verification success > 90%
- Database sync accuracy > 99%
- App Store rejection rate = 0%

### Business Metrics
- Subscription conversion rate (track baseline)
- Average revenue per user (ARPU)
- Subscription churn rate
- Customer lifetime value (LTV)

### Support Metrics
- Subscription-related support tickets (should be <5% of total)
- Average resolution time
- User satisfaction score

---

## 🔍 Known Limitations (Document for Users)

1. **Sandbox Testing**:
   - Receipt validation shows "Status 21002" in simulator (expected behavior)
   - Subscriptions renew faster in sandbox for testing

2. **Cancellation Process**:
   - Users must cancel through iOS Settings (Apple requirement)
   - App provides guidance but cannot cancel directly

3. **Restore Purchases**:
   - Currently requires manual refresh
   - Will be improved in future release with dedicated button

4. **Subscription Sync**:
   - May take up to 60 seconds to reflect in app after App Store changes
   - Use refresh button to force immediate sync

5. **Offline Purchases**:
   - Purchase can complete offline
   - Verification requires internet connection
   - Pending verifications will retry when online

---

## 📚 Resources & References

### Apple Documentation
- [In-App Purchase Programming Guide](https://developer.apple.com/in-app-purchase/)
- [StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- [Receipt Validation Guide](https://developer.apple.com/documentation/appstorereceipts)
- [Auto-Renewable Subscriptions](https://developer.apple.com/app-store/subscriptions/)

### Supabase Documentation
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Edge Functions](https://supabase.com/docs/guides/functions)
- [Database Functions & Triggers](https://supabase.com/docs/guides/database/functions)

### Internal Documentation
- [IAP_SUBSCRIPTION_SETUP.md](IAP_SUBSCRIPTION_SETUP.md) - Initial setup guide
- [SUBSCRIPTION_DEBUG_GUIDE.md](SUBSCRIPTION_DEBUG_GUIDE.md) - Debugging common issues
- [SUBSCRIPTION_SYNC_COMPLETE.md](SUBSCRIPTION_SYNC_COMPLETE.md) - Sync implementation details
- [SUBSCRIPTION_SOLUTION_COMPLETE.md](SUBSCRIPTION_SOLUTION_COMPLETE.md) - Complete solution overview

---

## 🆘 Support & Escalation

### For Development Issues
- Check console logs with filter: `IAPService|IAPVerification|SubscriptionSync`
- Review Edge Function logs in Supabase Dashboard
- Check database `user_subscriptions` table for status

### For User Support Issues
1. Ask user for:
   - Purchase receipt screenshot
   - User email
   - Approximate purchase time
2. Check database for user's subscription record
3. Verify transaction in App Store Connect → Sales and Trends
4. If needed, manually update database and ask user to refresh

### Escalation Path
1. Developer → Senior Developer
2. Senior Developer → CTO
3. CTO → Apple Developer Support (for App Store issues)
4. CTO → Supabase Support (for infrastructure issues)

---

## 🎯 Next Steps (Post-MVP)

### Version 3.1 (Planned Enhancements)
- [ ] Add subscription upgrade/downgrade flow
- [ ] Implement promotional codes
- [ ] Add subscription analytics dashboard
- [ ] Create admin panel for subscription management
- [ ] Add webhook for Apple server notifications
- [ ] Implement offline verification queue

### Version 3.2 (Future Considerations)
- [ ] Add family sharing support
- [ ] Implement grace period for failed renewals
- [ ] Add win-back campaigns for churned users
- [ ] A/B test pricing
- [ ] Add subscription gifting
- [ ] Multi-platform sync (Android)

---

## ✅ Final Recommendation

**Current Status**: MVP subscription system is **functionally complete** but has critical configuration gaps.

**Timeline to Production**:
- **Critical Fixes**: 1-2 days
- **Testing**: 3-5 days
- **App Review**: 1-2 weeks
- **Total**: ~3 weeks

**Recommended Action**:
1. ✅ Complete all 10 critical fixes (priority 1)
2. ✅ Complete moderate priority fixes (priority 2)
3. ✅ Conduct thorough TestFlight testing
4. ✅ Submit to App Store
5. 🎉 Launch!

**Risk Level**: Currently **MODERATE-HIGH** → Will be **LOW** after critical fixes

---

**Document Version**: 1.0
**Last Updated**: April 24, 2026
**Next Review**: Before App Store submission
**Owner**: Development Team
**Approved By**: Pending CTO Review
