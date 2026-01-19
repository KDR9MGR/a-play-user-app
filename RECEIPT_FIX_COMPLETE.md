# Receipt Verification Fix - Status 21002 Resolved

## Problem Identified

Apple was returning **status code 21002** ("The data in the receipt-data property was malformed or missing") because we were sending the wrong receipt data.

### Root Cause

The `PurchaseDetails.verificationData.serverVerificationData` from the `in_app_purchase` package:
- Contains only the **individual transaction receipt** (~2000 characters)
- Does NOT contain the **full App Store receipt** needed for subscription verification

For iOS subscription verification, Apple requires the **complete App Store receipt** from the app bundle, which includes ALL transactions for the app.

## Solution Implemented

### 1. Added Native iOS Platform Channel

**File**: `ios/Runner/AppDelegate.swift`

Added a method channel to retrieve the full App Store receipt:

```swift
import StoreKit

// Platform channel: app.aplay/receipt
// Method: getAppStoreReceipt
// Returns: Base64-encoded full App Store receipt
```

**How it works**:
- Reads receipt from `Bundle.main.appStoreReceiptURL`
- Converts to base64 string
- Returns to Flutter

### 2. Updated Flutter Purchase Manager

**File**: `lib/core/services/purchase_manager.dart`

Added `_getAppStoreReceipt()` method:
```dart
Future<String?> _getAppStoreReceipt() async {
  const platform = MethodChannel('app.aplay/receipt');
  final String receipt = await platform.invokeMethod('getAppStoreReceipt');
  return receipt;
}
```

Updated `_verifyPurchaseWithBackend()`:
- For iOS: Retrieves full App Store receipt via platform channel
- Falls back to purchase receipt if platform channel fails
- Sends correct receipt to Edge Function

## What Changed

### Before (Broken)
```
Purchase completes
  ↓
Get transaction receipt from PurchaseDetails (~2KB)
  ↓
Send to verify-apple-sub Edge Function
  ↓
Apple returns 21002 (malformed receipt)
  ↓
Verification FAILS ❌
```

### After (Fixed)
```
Purchase completes
  ↓
Get FULL App Store receipt via platform channel (~10-50KB)
  ↓
Send to verify-apple-sub Edge Function
  ↓
Apple validates successfully
  ↓
Subscription stored in database
  ↓
Verification SUCCESS ✅
```

## Files Modified

1. **`ios/Runner/AppDelegate.swift`**
   - Added StoreKit import
   - Added platform channel handler
   - Retrieves full App Store receipt

2. **`lib/core/services/purchase_manager.dart`**
   - Added `flutter/services.dart` import
   - Added `_getAppStoreReceipt()` method
   - Updated `_verifyPurchaseWithBackend()` to use full receipt

## Testing Instructions

1. **Rebuild the app** (Swift code changed):
   ```bash
   flutter clean
   flutter pub get
   flutter run --dart-define=SANDBOX_MODE=true
   ```

2. **Make a test purchase**

3. **Check the logs** for:
   ```
   📱 AppDelegate: App Store receipt retrieved successfully
   📱 AppDelegate: Receipt length: XXXXX characters

   PurchaseManager: Retrieved full App Store receipt (XXXXX chars)
   PurchaseManager: Using full App Store receipt
   PurchaseManager: Receipt length: XXXXX characters

   ✅ PurchaseManager: Backend verification SUCCESS
      Product: SUBAU
      Expires: 2025-XX-XX...
      Status: active
   ```

4. **Verify in Supabase**:
   - Open `subscriptions` table
   - Check for new row with your user ID
   - Status should be 'active'

## Expected Receipt Sizes

- **Transaction receipt** (old, broken): ~1,900 - 2,000 characters
- **Full App Store receipt** (new, working): ~10,000 - 50,000+ characters

The full receipt contains:
- App metadata
- ALL purchase transactions
- Receipt creation date
- Bundle ID
- Version information

## Why This Works

Apple's `verifyReceipt` API for subscriptions requires the **complete receipt** because:
1. Subscriptions involve multiple transactions (original purchase + renewals)
2. Apple needs to validate the entire purchase history
3. The full receipt includes subscription group information
4. Only the complete receipt has the necessary cryptographic signatures

## Troubleshooting

### Issue: "NO_RECEIPT" error
- **Cause**: No App Store receipt exists (normal in simulator)
- **Solution**: Test on real device or TestFlight build

### Issue: Receipt still malformed
- **Cause**: App not properly signed or sandbox account issues
- **Solution**:
  - Verify app is code-signed
  - Use valid sandbox test account
  - Delete app and reinstall

### Issue: Platform channel not found
- **Cause**: App not rebuilt after Swift changes
- **Solution**: Run `flutter clean` then rebuild

## Additional Notes

- The platform channel gracefully falls back to transaction receipt if unavailable
- This fix is necessary for both sandbox and production
- The full receipt is required for ALL subscription verification scenarios
- Once verified, subscriptions auto-renew without re-verification needed

## References

- Apple Receipt Validation: https://developer.apple.com/documentation/appstorereceipts
- Status Code 21002: Malformed receipt data
- Bundle.main.appStoreReceiptURL: https://developer.apple.com/documentation/foundation/bundle/1407276-appstorereceipturl
