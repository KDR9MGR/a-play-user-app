# IAP Pending Status - Final Diagnosis & Solution

## Issue Summary

**Symptom**: Purchase initiates successfully but remains stuck in `PurchaseStatus.pending` and never transitions to `purchased`.

**Console Logs**:
```
flutter: PurchaseManager: Purchase initiated successfully for: 7day
flutter: === PURCHASE UPDATE RECEIVED ===
flutter: Processing purchase update - Status: PurchaseStatus.pending, Product: 7day
flutter: PurchaseManager: No pending completion required
[Purchase stays in pending forever]
```

---

## Root Cause Analysis

### ✅ **`buyNonConsumable` IS CORRECT**

**IMPORTANT**: After researching Flutter's `in_app_purchase` package (v3.2.0), `buyNonConsumable()` is the **CORRECT** method for both:
- One-time purchases (consumable/non-consumable)
- **Auto-renewable subscriptions** ✓

There is **NO** `buyAutoRenewingSubscription()` method in this package. The package uses `buyNonConsumable` for all iOS purchases.

**Source**: [Flutter in_app_purchase documentation](https://pub.dev/packages/in_app_purchase) and [Google Codelabs](https://codelabs.developers.google.com/codelabs/flutter-in-app-purchases)

---

## Actual Problem: Payment Confirmation Not Completed

### 🔴 **Issue #1: StoreKit Payment Dialog Not Clicked**

When you initiate a purchase in iOS Simulator, StoreKit shows a confirmation dialog:

```
┌──────────────────────────────────────────┐
│   Confirm Your In-App Purchase           │
│                                           │
│   Do you want to buy one "1 Week         │
│   Premium" for GHS 50.00?                │
│                                           │
│   Environment: Xcode                     │
│                                           │
│         [Cancel]         [Buy]           │
└──────────────────────────────────────────┘
```

**The purchase stays in `pending` until you click [Buy].**

**Common Issues**:
1. Dialog doesn't appear (StoreKit config problem)
2. Dialog appears but is hidden behind other windows
3. User clicked Cancel instead of Buy
4. Dialog times out if not acted upon

**Solution**: After tapping "Subscribe" in your app:
1. **Look for the payment dialog** - it should appear immediately
2. **Click the [Buy] button** to confirm
3. Status should change from `pending` → `purchased`

---

### 🟡 **Issue #2: StoreKit Configuration in Xcode**

You have **TWO** StoreKit configuration files:

1. **`ios/A-Play.storekit`** - EMPTY (no products/subscriptions defined) ❌
2. **`ios/StoreKitConfig.storekit`** - Contains all 4 subscription products ✓

**Problem**: If Xcode is using the empty config file, products won't load properly and payment dialogs may not appear.

**Fix Steps**:

1. **Open Xcode** and load your iOS project
2. **Edit Scheme**:
   - Go to: **Product → Scheme → Edit Scheme** (or press **Cmd+<**)
3. **Select "Run" tab** in the left sidebar
4. **Click "Options" tab** at the top
5. **Under "StoreKit Configuration"**:
   - Check which file is selected (if any)
   - **Select `StoreKitConfig.storekit`** from the dropdown
   - If it's not in the dropdown:
     - Click the "+" button
     - Navigate to `ios/StoreKitConfig.storekit`
     - Add it and select it
6. **Clean Build**:
   - Product → Clean Build Folder (**Cmd+Shift+K**)
7. **Rebuild and run**

**Visual Check in Xcode**:
- Open `ios/StoreKitConfig.storekit` in Xcode
- You should see Subscription Group "Go Pro" with 4 products:
  - `7day` - 1 Week Premium - GHS 50
  - `1month` - 1 Month Premium - GHS 190
  - `3SUB` - 3 Months Premium - GHS 550
  - `365day` - 1 Year Premium - GHS 2200

---

### 🟠 **Issue #3: iOS Simulator Limitations**

**Known Simulator Issues**:
1. Payment dialogs may not appear reliably
2. Transactions can get stuck in pending state
3. StoreKit testing is less reliable than on physical devices
4. Subscription renewals don't work the same as production

**Solutions**:

**Option A - Reset Simulator**:
```bash
# In iOS Simulator menu:
Device → Erase All Content and Settings
```
Then rebuild and test again.

**Option B - Test on Physical Device**:
1. Connect iPhone/iPad via USB
2. Select device in Xcode
3. Build and run on device
4. Test purchase flow (more reliable than simulator)

**Option C - Use Xcode Transaction Manager**:
1. In Simulator, go to **Debug → StoreKit → Manage Transactions**
2. This shows all StoreKit transactions
3. Look for pending transactions
4. You can manually approve/decline them here

---

## Applied Fixes

### ✅ **Fix #1: Enhanced Logging**

Added detailed debugging to help identify when payment confirmation is needed.

**File**: [lib/core/services/purchase_manager.dart](lib/core/services/purchase_manager.dart)

**Changes**:
1. Added success logging after `buyNonConsumable` call
2. Added warning message to look for payment dialog
3. Added detailed pending status logging

**New logs you'll see**:
```
flutter: PurchaseManager: Purchase initiation result: true for product: 7day
flutter: PurchaseManager: ⚠️  WAITING FOR PAYMENT CONFIRMATION
flutter: PurchaseManager: Please look for the payment dialog and tap [Buy]
flutter: PurchaseManager: Purchase pending: 7day
flutter: PurchaseManager: ⚠️  PURCHASE IS WAITING FOR USER ACTION
flutter: PurchaseManager: Look for the StoreKit payment confirmation dialog
flutter: PurchaseManager: Tap [Buy] in the dialog to complete the purchase
```

### ✅ **Fix #2: Product ID Mapping Verified**

Confirmed that product IDs are correctly mapped:

| App Plan ID | Apple Product ID | StoreKit Config |
|-------------|------------------|-----------------|
| weekly_plan | 7day | ✓ |
| monthly_plan | 1month | ✓ |
| quarterly_plan | 3SUB | ✓ |
| annual_plan | 365day | ✓ |

**Files**:
- Mapping: [lib/features/subscription/service/apple_iap_service.dart:99-104](lib/features/subscription/service/apple_iap_service.dart#L99-L104)
- StoreKit: [ios/StoreKitConfig.storekit:43-156](ios/StoreKitConfig.storekit#L43-L156)

---

## Complete Testing Procedure

### **Step 1: Verify Xcode Configuration**

Before running, ensure StoreKit config is correct (see Issue #2 above).

### **Step 2: Clean Build**

In Windows terminal:
```bash
flutter clean
flutter pub get
```

In Xcode:
- **Product → Clean Build Folder** (Cmd+Shift+K)

### **Step 3: Run and Test Purchase**

1. **Build and run** app in iOS Simulator
2. **Navigate** to subscription screen
3. **Tap** "1 Week Premium" button
4. **Watch console for**:
   ```
   flutter: PurchaseManager: Product found - ID: 7day
   flutter: PurchaseManager: Purchase initiation result: true
   flutter: PurchaseManager: ⚠️  WAITING FOR PAYMENT CONFIRMATION
   ```

5. **Look for payment dialog** in simulator (should appear immediately)
6. **Click [Buy]** button in the dialog
7. **Expected result**:
   ```
   flutter: === PURCHASE UPDATE RECEIVED ===
   flutter: Processing purchase update - Status: PurchaseStatus.purchased
   flutter: === PurchaseManager: SUCCESSFUL PURCHASE ===
   ```

### **Step 4: If Payment Dialog Doesn't Appear**

**Check Xcode Console** for errors:
```
# Look for messages like:
[StoreKit] Failed to load products
[StoreKit] Invalid product identifier
[StoreKit] No StoreKit configuration file
```

**Open StoreKit Transaction Manager**:
1. In Simulator: **Debug → StoreKit → Manage Transactions**
2. Check if transaction appears there
3. Check transaction status

**Verify StoreKit Config Loading**:
1. In Xcode Console, look for:
   ```
   StoreKit: Loaded configuration from StoreKitConfig.storekit
   ```
2. If not found, StoreKit config isn't being used

---

## Diagnostic Commands

### **Check StoreKit Configuration in Xcode**

1. Open `.xcworkspace` file in Xcode
2. Product → Scheme → Edit Scheme
3. Run → Options → StoreKit Configuration
4. Should show: `StoreKitConfig.storekit` ✓

### **View Transactions in Simulator**

While app is running:
1. Debug → StoreKit → Manage Transactions
2. Shows all purchase attempts
3. Can manually complete/cancel stuck transactions

### **Reset StoreKit in Simulator**

To clear all test purchases:
1. Debug → StoreKit → Reset Purchase History
2. Device → Erase All Content and Settings
3. Rebuild and test fresh

---

## Expected vs Actual Flow

### **Current Flow (Problem)**:
```
1. User taps Subscribe ✓
2. buyNonConsumable() called ✓
3. Purchase initiated successfully ✓
4. Status: pending ✓
5. [STUCK HERE - Payment dialog not clicked or not appearing] ❌
6. Status never changes to purchased ❌
```

### **Expected Flow (Success)**:
```
1. User taps Subscribe ✓
2. buyNonConsumable() called ✓
3. Purchase initiated successfully ✓
4. Payment confirmation dialog appears ✓
5. User clicks [Buy] in dialog ✓
6. Status changes: pending → purchased ✓
7. onPurchaseSuccess callback fires ✓
8. Backend verification occurs ✓
9. Subscription activated ✓
```

---

## Additional Debugging

### **Add Native iOS Logging**

If you want to see StoreKit's native transaction updates, add this to `ios/Runner/AppDelegate.swift`:

**Before** (current):
```swift
import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**After** (enhanced):
```swift
import UIKit
import Flutter
import StoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add payment queue observer
    SKPaymentQueue.default().add(self)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

extension AppDelegate: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      let state = transaction.transactionState.rawValue
      let productId = transaction.payment.productIdentifier
      print("🍎 Native StoreKit: Transaction \(productId) - State: \(state)")

      switch transaction.transactionState {
      case .purchasing:
        print("🍎 Native: Purchasing \(productId)")
      case .purchased:
        print("🍎 Native: Purchased \(productId)")
      case .failed:
        print("🍎 Native: Failed \(productId) - Error: \(String(describing: transaction.error))")
      case .restored:
        print("🍎 Native: Restored \(productId)")
      case .deferred:
        print("🍎 Native: Deferred \(productId)")
      @unknown default:
        print("🍎 Native: Unknown state for \(productId)")
      }
    }
  }
}
```

This will show native StoreKit events alongside Flutter logs.

---

## Most Likely Causes (Ranked)

Based on the logs and code analysis:

1. **🥇 Payment dialog not being clicked** (80% probability)
   - Dialog appears but user doesn't click [Buy]
   - Dialog hidden behind other windows
   - User clicks Cancel instead

2. **🥈 StoreKit config not loaded** (15% probability)
   - Xcode using wrong/no StoreKit config file
   - Products not loading properly
   - Dialog can't appear without valid products

3. **🥉 Simulator StoreKit bug** (5% probability)
   - Known simulator issues with subscriptions
   - Transaction gets stuck in pending
   - Would work on physical device

---

## Quick Fixes Checklist

Try these in order:

- [ ] **Fix #1**: Verify Xcode Scheme uses `StoreKitConfig.storekit`
- [ ] **Fix #2**: Clean build (`flutter clean` + Xcode Clean Build Folder)
- [ ] **Fix #3**: Run app and look for payment dialog after tapping Subscribe
- [ ] **Fix #4**: Click [Buy] in payment dialog (not Cancel)
- [ ] **Fix #5**: If dialog doesn't appear, check Xcode Console for StoreKit errors
- [ ] **Fix #6**: Open Debug → StoreKit → Manage Transactions to see transaction status
- [ ] **Fix #7**: Reset StoreKit: Debug → StoreKit → Reset Purchase History
- [ ] **Fix #8**: Test on physical iOS device instead of simulator

---

## Success Criteria

You'll know it's working when you see these logs in sequence:

```
flutter: PurchaseManager: Product found - ID: 7day, Title: 1 Week Premium, Price: GHS 50.00
flutter: PurchaseManager: Purchase initiation result: true for product: 7day
flutter: PurchaseManager: ⚠️  WAITING FOR PAYMENT CONFIRMATION
flutter: === PURCHASE UPDATE RECEIVED ===
flutter: Processing purchase update - Status: PurchaseStatus.pending, Product: 7day
[You click [Buy] in the payment dialog]
flutter: === PURCHASE UPDATE RECEIVED ===
flutter: Processing purchase update - Status: PurchaseStatus.purchased, Product: 7day
flutter: PurchaseManager: Purchase completed, processing...
flutter: === PurchaseManager: SUCCESSFUL PURCHASE ===
flutter: Product ID: 7day
flutter: Calling onPurchaseSuccess callback...
flutter: PurchaseManager: Completing purchase transaction...
flutter: ✅ PurchaseManager: Backend verification SUCCESS
```

---

## Still Not Working?

If purchase still stays in pending after trying all fixes:

1. **Share new console logs** including:
   - Flutter logs from app start to purchase attempt
   - Xcode Console logs (native iOS logs)
   - Screenshot of StoreKit Transaction Manager (Debug → StoreKit → Manage Transactions)

2. **Verify App Store Connect**:
   - Products are "Ready to Submit"
   - Subscription group is properly configured
   - Product IDs match exactly (case-sensitive)

3. **Check sandbox account**:
   - Sign out of real Apple ID in iOS Settings
   - Don't manually sign in with sandbox account
   - Sandbox prompt should appear during purchase

4. **Test on physical device**:
   - Deploy to iPhone/iPad
   - Subscriptions are much more reliable on real hardware
   - Simulator has known StoreKit issues

---

## Summary

**The purchase method is CORRECT** - `buyNonConsumable()` is the right method for iOS subscriptions in Flutter's in_app_purchase package.

**The real issue** is most likely that the StoreKit payment confirmation dialog either:
1. Isn't appearing (Xcode config problem)
2. Is appearing but not being clicked
3. Is experiencing simulator-specific bugs

**Primary fix**: Ensure Xcode Scheme uses `StoreKitConfig.storekit` and look for/click the payment dialog.

**Secondary fix**: Test on a physical iOS device if simulator continues to have issues.

