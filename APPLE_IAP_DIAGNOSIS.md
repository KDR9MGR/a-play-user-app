# Apple IAP Purchase Stuck in Pending - Diagnosis & Solution

## Problem Summary
Purchase is stuck in `PurchaseStatus.pending` and never completes. The logs show:
```
flutter: PurchaseStatus.pending, Product: 7day
flutter: PurchaseManager: No pending completion required
```

## Root Causes Identified

### 1. **CRITICAL: Incorrect Purchase Method for Subscriptions**

**Location**: [lib/core/services/purchase_manager.dart:199](lib/core/services/purchase_manager.dart#L199)

```dart
// WRONG for auto-renewable subscriptions
final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
```

**Problem**: `buyNonConsumable` is for permanent unlocks (one-time purchases), NOT for auto-renewable subscriptions.

**Impact**:
- Subscriptions may not renew automatically
- Purchase completion flow is incorrect
- StoreKit treats the purchase differently

**Solution**: Change to:
```dart
final bool success = await _inAppPurchase.buyAutoRenewingSubscription(purchaseParam: purchaseParam);
```

---

### 2. **Product ID Mapping is Correct** ✓

The product ID mapping is working correctly:

| App Plan ID | Apple Product ID | StoreKit Config |
|-------------|------------------|-----------------|
| weekly_plan | 7day | ✓ Present |
| monthly_plan | 1month | ✓ Present |
| quarterly_plan | 3SUB | ✓ Present |
| annual_plan | 365day | ✓ Present |

**Files**:
- Mapping: [lib/features/subscription/service/apple_iap_service.dart:99-104](lib/features/subscription/service/apple_iap_service.dart#L99-L104)
- StoreKit: [ios/StoreKitConfig.storekit](ios/StoreKitConfig.storekit)

---

### 3. **Pending Status Handling**

**Location**: [lib/core/services/purchase_manager.dart:272-275](lib/core/services/purchase_manager.dart#L272-L275)

```dart
case PurchaseStatus.pending:
  if (kDebugMode) print('PurchaseManager: Purchase pending: ${purchaseDetails.productID}');
  break;
```

**Issue**: The code doesn't handle pending state actively. Pending is normal for:
- User hasn't confirmed purchase in payment sheet
- Parental approval required (Ask to Buy)
- Payment processing by Apple

**Current behavior**: Logs "No pending completion required" (line 304) because `pendingCompletePurchase` is false for pending purchases.

**This is technically correct** - you shouldn't complete pending purchases. But the purchase method needs to be fixed (#1).

---

### 4. **StoreKit Configuration Files**

You have TWO StoreKit configuration files:

1. **[ios/A-Play.storekit](ios/A-Play.storekit)** - EMPTY (no products/subscriptions)
2. **[ios/StoreKitConfig.storekit](ios/StoreKitConfig.storekit)** - Has all subscription products ✓

**Issue**: Xcode might be using the wrong file.

**Solution**: Verify Xcode scheme is using `StoreKitConfig.storekit`:
- Open Xcode → Product → Scheme → Edit Scheme
- Select "Run" tab → Options
- Under "StoreKit Configuration", ensure `StoreKitConfig.storekit` is selected
- If not present, add it

---

## Solutions - Priority Order

### 🔴 **URGENT: Fix #1 - Change Purchase Method**

**File**: [lib/core/services/purchase_manager.dart:199](lib/core/services/purchase_manager.dart#L199)

**Change from**:
```dart
final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
```

**Change to**:
```dart
final bool success = await _inAppPurchase.buyAutoRenewingSubscription(purchaseParam: purchaseParam);
```

This is the most critical fix.

---

### 🟡 **IMPORTANT: Verify Xcode StoreKit Configuration**

1. Open Xcode
2. Go to: **Product → Scheme → Edit Scheme**
3. Select **Run** tab → **Options**
4. Under **StoreKit Configuration**:
   - Ensure `StoreKitConfig.storekit` is selected
   - If not, click dropdown and select it
5. Clean build: **Product → Clean Build Folder** (Cmd+Shift+K)
6. Rebuild and run

---

### 🟢 **OPTIONAL: Clean Up Duplicate StoreKit File**

Since `A-Play.storekit` is empty and unused, you can either:

**Option A - Delete it** (recommended):
```bash
rm ios/A-Play.storekit
```

**Option B - Sync it** (if you want to keep both):
- Copy the subscription group from `StoreKitConfig.storekit` to `A-Play.storekit`
- Update Xcode scheme to use `A-Play.storekit` instead

---

### 🔵 **RECOMMENDED: Add Better Pending State UI**

**File**: [lib/core/services/purchase_manager.dart:272-275](lib/core/services/purchase_manager.dart#L272-L275)

**Current**:
```dart
case PurchaseStatus.pending:
  if (kDebugMode) print('PurchaseManager: Purchase pending: ${purchaseDetails.productID}');
  break;
```

**Enhanced** (optional callback):
```dart
case PurchaseStatus.pending:
  if (kDebugMode) print('PurchaseManager: Purchase pending: ${purchaseDetails.productID}');
  onPurchasePending?.call(purchaseDetails.productID); // Add this callback
  break;
```

This would allow the UI to show "Processing payment..." or similar.

---

## Testing Checklist

After applying fixes:

- [ ] Fix #1: Change `buyNonConsumable` to `buyAutoRenewingSubscription`
- [ ] Ask user to run: `flutter packages pub run build_runner build`
- [ ] Verify Xcode StoreKit configuration points to `StoreKitConfig.storekit`
- [ ] Clean build in Xcode (Cmd+Shift+K)
- [ ] Run app on iOS simulator
- [ ] Attempt subscription purchase
- [ ] Verify purchase completes (status should change from pending → purchased)
- [ ] Check logs for success confirmation
- [ ] Test with all 4 subscription plans (7day, 1month, 3SUB, 365day)

---

## App Store Connect Configuration

Your subscription group setup looks correct:

**Subscription Group**: "Go Pro" (ID: 21809726)

| Product ID | Display Name | Price (GHS) | Period | Status |
|------------|-------------|-------------|---------|---------|
| 7day | 1 Week Premium | 50 | P1W | ✓ |
| 1month | 1 Month Premium | 190 | P1M | ✓ |
| 3SUB | 3 Months Premium | 550 | P3M | ✓ |
| 365day | 1 Year Premium | 2200 | P1Y | ✓ |

**Note**: Ensure these are marked as "Ready to Submit" in App Store Connect before production testing.

---

## Why It's Stuck in Pending

Based on the code analysis, the purchase is stuck because:

1. **Wrong purchase method**: `buyNonConsumable` might cause StoreKit to handle the transaction differently
2. **Simulator limitations**: Subscriptions in simulator can be flaky - test on physical device
3. **User action required**: In simulator, you need to explicitly confirm the purchase in the payment sheet
4. **StoreKit config mismatch**: If Xcode is using the empty `A-Play.storekit`, products won't be found

**Most likely cause**: #1 (wrong purchase method) combined with #4 (wrong StoreKit config file).

---

## Next Steps

1. Apply fix #1 (change purchase method)
2. Verify Xcode StoreKit configuration
3. Test on physical iOS device (subscriptions are more reliable than simulator)
4. If still failing, check App Store Connect to ensure products are "Ready to Submit"
5. Enable "Ask to Buy" in StoreKit config for testing approval flows

---

## Additional Notes

- The purchase completion logic (lines 295-305) is actually correct for subscriptions - they shouldn't be manually completed
- The mapping between plan IDs and product IDs is working correctly
- The backend verification with Supabase Edge Function looks good
- Firebase Crashlytics warnings in logs are unrelated to IAP issue

