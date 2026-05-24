# IAP Stuck in Pending Status - Comprehensive Fix

## Current Issue Analysis

Based on the logs you provided:

```
flutter: PurchaseManager: Purchase initiated successfully for: 7day
flutter: === PURCHASE UPDATE RECEIVED ===
flutter: Processing purchase update - Status: PurchaseStatus.pending, Product: 7day
flutter: PurchaseManager: Purchase pending: 7day
flutter: PurchaseManager: No pending completion required
```

**What's happening:**
1. ✅ Purchase is initiated successfully
2. ✅ StoreKit receives the purchase request
3. ❌ Purchase stays in `PurchaseStatus.pending` and never transitions to `purchased`
4. ❌ `pendingCompletePurchase` is `false`, so the transaction isn't completed

---

## Root Causes (Multiple Issues)

### 🔴 **Issue #1: WRONG PURCHASE METHOD** (CRITICAL)

**Location**: [lib/core/services/purchase_manager.dart:198](lib/core/services/purchase_manager.dart#L198)

**Current Code**:
```dart
await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
```

**Problem**: `buyNonConsumable` is for **permanent one-time purchases** (like "Remove Ads" or "Unlock Pro Version"), NOT for **auto-renewable subscriptions**.

**Impact**:
- StoreKit doesn't recognize this as a subscription
- Renewal logic won't work
- Transaction flow is incorrect
- Purchase may not complete properly

**Required Fix**:
```dart
await _inAppPurchase.buyAutoRenewingSubscription(purchaseParam: purchaseParam);
```

Or if you want to support BOTH subscriptions AND one-time purchases:
```dart
// Detect if product is a subscription
final isSubscription = productDetails is AppStoreProductDetails &&
    (productDetails as AppStoreProductDetails).skProduct.subscriptionPeriod != null;

if (isSubscription) {
  await _inAppPurchase.buyAutoRenewingSubscription(purchaseParam: purchaseParam);
} else {
  await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
}
```

---

### 🟡 **Issue #2: PAYMENT CONFIRMATION IN SIMULATOR**

**What's happening**: In iOS Simulator, when you tap "Subscribe", a payment confirmation dialog appears:

```
┌─────────────────────────────────┐
│  Confirm Your In-App Purchase   │
│                                  │
│  Do you want to buy one "1 Week │
│  Premium" for GHS 50.00?        │
│                                  │
│  [Environment: Xcode]           │
│                                  │
│       [Cancel]    [Buy]         │
└─────────────────────────────────┘
```

**Problem**: You MUST click **[Buy]** to complete the purchase. The purchase stays in `pending` until you confirm.

**Common Issues**:
- Dialog might be hidden behind other windows
- Simulator might not show dialog (StoreKit config issue)
- User accidentally clicked Cancel or closed dialog

**Solution**:
1. After tapping "Subscribe" in your app, **look for the payment dialog**
2. Make sure it appears in the simulator
3. Click **[Buy]** to confirm
4. The status should change from `pending` → `purchased`

---

### 🟠 **Issue #3: STOREKIT CONFIGURATION IN XCODE**

**Problem**: You have TWO StoreKit config files, and Xcode might be using the wrong one:
- `ios/A-Play.storekit` (EMPTY - no products)
- `ios/StoreKitConfig.storekit` (HAS ALL 4 SUBSCRIPTIONS ✓)

**Fix Steps**:

1. **Open Xcode** and load your project
2. **Edit Scheme**: Product → Scheme → Edit Scheme (or Cmd+<)
3. **Select "Run" tab** on the left
4. **Click "Options" tab** at the top
5. **Under "StoreKit Configuration"**:
   - Check if a config file is selected
   - If none, or if it shows `A-Play.storekit`, change it to `StoreKitConfig.storekit`
   - If `StoreKitConfig.storekit` isn't in the dropdown:
     - Click "+" to add it
     - Navigate to `ios/StoreKitConfig.storekit`
     - Select it

6. **Clean Build Folder**: Product → Clean Build Folder (Cmd+Shift+K)
7. **Rebuild and Run**

---

### 🟢 **Issue #4: SUBSCRIPTION PRODUCTS NOT PROPERLY CONFIGURED**

**Verify in StoreKit Config**:

Open `ios/StoreKitConfig.storekit` in Xcode and verify:

✅ **Expected Configuration**:
- Subscription Group: "Go Pro"
- Products:
  - `7day` - 1 Week Premium - GHS 50 - Recurring (P1W)
  - `1month` - 1 Month Premium - GHS 190 - Recurring (P1M)
  - `3SUB` - 3 Months Premium - GHS 550 - Recurring (P3M)
  - `365day` - 1 Year Premium - GHS 2200 - Recurring (P1Y)

All products should have:
- Type: **RecurringSubscription**
- Status: **Active/Ready**

---

### 🔵 **Issue #5: SIMULATOR LIMITATIONS**

**Known iOS Simulator Issues with Subscriptions**:
1. Payment confirmation dialogs may not appear reliably
2. StoreKit transactions can be slow or get stuck
3. Subscription renewals don't work the same as on device
4. Some subscription features are simulator-only (don't work in production)

**Solution**: Test on a **physical iOS device** with TestFlight or Xcode deployment.

---

## Complete Fix - Step by Step

### **Step 1: Fix the Purchase Method**

Edit [lib/core/services/purchase_manager.dart:197-204](lib/core/services/purchase_manager.dart#L197-L204):

**Replace this**:
```dart
try {
  await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  if (kDebugMode) print('PurchaseManager: Purchase initiated successfully for: $productId');
} catch (e) {
  final errorMsg = 'Purchase failed for $productId: $e';
  if (kDebugMode) print('PurchaseManager: $errorMsg');
  onPurchaseError?.call(errorMsg);
}
```

**With this**:
```dart
try {
  // CRITICAL: Use correct method for auto-renewable subscriptions
  await _inAppPurchase.buyAutoRenewingSubscription(purchaseParam: purchaseParam);
  if (kDebugMode) print('PurchaseManager: Subscription purchase initiated successfully for: $productId');
} catch (e) {
  final errorMsg = 'Purchase failed for $productId: $e';
  if (kDebugMode) print('PurchaseManager: $errorMsg');
  onPurchaseError?.call(errorMsg);
}
```

### **Step 2: Add Debugging for Pending Status**

To help diagnose, add more logging in the pending case. Edit [lib/core/services/purchase_manager.dart:266-268](lib/core/services/purchase_manager.dart#L266-L268):

**Replace**:
```dart
case PurchaseStatus.pending:
  if (kDebugMode) print('PurchaseManager: Purchase pending: ${purchaseDetails.productID}');
  break;
```

**With**:
```dart
case PurchaseStatus.pending:
  if (kDebugMode) {
    print('PurchaseManager: Purchase pending: ${purchaseDetails.productID}');
    print('PurchaseManager: ⚠️  WAITING FOR USER CONFIRMATION IN PAYMENT SHEET');
    print('PurchaseManager: Please look for the payment confirmation dialog and tap [Buy]');
  }
  break;
```

### **Step 3: Verify Xcode StoreKit Configuration**

Follow the steps in Issue #3 above to ensure `StoreKitConfig.storekit` is selected.

### **Step 4: Clean and Rebuild**

Run in Windows terminal:
```bash
flutter clean
flutter pub get
```

In Xcode:
- Clean Build Folder (Cmd+Shift+K)
- Rebuild and Run

---

## Testing Procedure

### **Test 1: Simulator Purchase Flow**

1. Run app in iOS Simulator
2. Navigate to subscription screen
3. Tap on "1 Week Premium" (7day product)
4. **Watch the console logs**:
   ```
   flutter: PurchaseManager: Product found - ID: 7day, Title: ..., Price: ...
   flutter: PurchaseManager: Subscription purchase initiated successfully for: 7day
   flutter: === PURCHASE UPDATE RECEIVED ===
   flutter: Processing purchase update - Status: PurchaseStatus.pending, Product: 7day
   flutter: PurchaseManager: ⚠️  WAITING FOR USER CONFIRMATION IN PAYMENT SHEET
   ```

5. **Look for the payment confirmation dialog** (might be hidden)
6. **Click [Buy]** to confirm
7. **Expected logs after confirmation**:
   ```
   flutter: === PURCHASE UPDATE RECEIVED ===
   flutter: Processing purchase update - Status: PurchaseStatus.purchased, Product: 7day
   flutter: PurchaseManager: Purchase completed, processing...
   flutter: === PurchaseManager: SUCCESSFUL PURCHASE ===
   flutter: Product ID: 7day
   flutter: Calling onPurchaseSuccess callback...
   ```

### **Test 2: Check Payment Dialog Appearance**

If the payment dialog doesn't appear:

1. Check Xcode Console for StoreKit errors
2. Verify StoreKit configuration is loaded:
   - Look for logs like: `StoreKit: Loaded configuration file`
3. Try resetting the simulator:
   - Device → Erase All Content and Settings
   - Rebuild and test again

### **Test 3: Physical Device Testing**

If simulator continues to have issues:

1. Connect physical iOS device
2. Select device in Xcode
3. Build and run on device
4. Test purchase flow
5. Subscriptions are more reliable on real devices

---

## What the Logs Tell Us

### **Current Logs (Problem)**:
```
flutter: PurchaseManager: Purchase initiated successfully for: 7day
flutter: Processing purchase update - Status: PurchaseStatus.pending, Product: 7day
flutter: PurchaseManager: No pending completion required
```

**Interpretation**:
- ✅ Purchase request sent to StoreKit
- ❌ User hasn't confirmed payment (or dialog didn't appear)
- ❌ Using wrong purchase method (`buyNonConsumable`)

### **Expected Logs (Success)**:
```
flutter: PurchaseManager: Subscription purchase initiated successfully for: 7day
flutter: Processing purchase update - Status: PurchaseStatus.pending, Product: 7day
flutter: PurchaseManager: ⚠️  WAITING FOR USER CONFIRMATION
[User clicks Buy in payment dialog]
flutter: Processing purchase update - Status: PurchaseStatus.purchased, Product: 7day
flutter: === PurchaseManager: SUCCESSFUL PURCHASE ===
flutter: Calling onPurchaseSuccess callback...
flutter: PurchaseManager: Completing purchase transaction...
flutter: PurchaseManager: Purchase transaction completed successfully
```

---

## Quick Diagnostic Checklist

Run through this checklist:

- [ ] **Fix #1**: Changed `buyNonConsumable` → `buyAutoRenewingSubscription`
- [ ] **Fix #2**: Verified StoreKit config in Xcode scheme (use `StoreKitConfig.storekit`)
- [ ] **Fix #3**: Cleaned build (`flutter clean` + Xcode Clean Build Folder)
- [ ] **Test #1**: Looked for payment confirmation dialog after tapping Subscribe
- [ ] **Test #2**: Clicked [Buy] button in payment dialog (not Cancel)
- [ ] **Test #3**: Checked Xcode console for StoreKit errors
- [ ] **Test #4**: Tried on physical iOS device (if simulator fails)

---

## Alternative: Add Transaction Observer

If the issue persists, you might need to add explicit transaction observation. This requires native iOS code:

**File**: `ios/Runner/AppDelegate.swift`

```swift
import StoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add StoreKit transaction observer
    SKPaymentQueue.default().add(self)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// Add StoreKit transaction observer
extension AppDelegate: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      print("StoreKit Native: Transaction state: \(transaction.transactionState.rawValue)")
      print("StoreKit Native: Product ID: \(transaction.payment.productIdentifier)")
    }
  }
}
```

This will show native StoreKit transaction updates separately from the Flutter plugin.

---

## Expected Outcome

After applying all fixes, the purchase flow should be:

1. User taps "Subscribe" → `buyAutoRenewingSubscription` called
2. Payment dialog appears → User sees "Confirm Your In-App Purchase"
3. User clicks [Buy] → Status changes from `pending` to `purchased`
4. Transaction completes → Success callback fires
5. Backend verification → Subscription activated

---

## Still Not Working?

If the purchase still doesn't complete after all fixes:

### **Check these additional issues**:

1. **App Store Connect Configuration**:
   - Ensure subscription products are "Ready to Submit" in App Store Connect
   - Verify product IDs exactly match (case-sensitive)
   - Check subscription group is properly configured

2. **Sandbox Tester Account**:
   - Sign out of real Apple ID in Settings → App Store
   - Don't sign in with sandbox account before testing
   - Sandbox credentials should be prompted during purchase

3. **Entitlements File**:
   - Verify `ios/Runner/Runner.entitlements` has In-App Purchase capability
   - Should contain: `<key>com.apple.developer.in-app-purchases</key><array/>`

4. **Bundle ID**:
   - Ensure Xcode bundle ID matches App Store Connect
   - Check provisioning profile includes In-App Purchase capability

---

## Next Steps

1. **Apply Fix #1** (change purchase method) - MOST CRITICAL
2. **Verify Xcode configuration** (StoreKit config file)
3. **Clean and rebuild**
4. **Test and watch for payment dialog**
5. **Share new logs** if issue persists

The most likely cause is **Issue #1** (wrong purchase method) combined with **Issue #2** (payment dialog not being clicked/appearing).

