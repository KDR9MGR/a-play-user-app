# Receipt Verification Issue - Apple Status 21002

## Problem

Apple is returning status code **21002** ("The data in the receipt-data property was malformed or missing") when we try to verify purchases.

The issue is that the receipt data from `PurchaseDetails.verificationData.serverVerificationData` is **not the correct App Store receipt** for iOS subscriptions.

## Root Cause

The `in_app_purchase` Flutter package's `serverVerificationData` field:
- On **Android**: Contains the purchase token (correct)
- On **iOS**: Contains a purchase receipt, but NOT the full App Store receipt needed for subscription verification

For iOS subscription verification, Apple requires the **full App Store receipt** from the app bundle, which contains ALL transactions.

## Solution Options

### Option 1: Use Platform Channel (Recommended)

Create a platform channel to get the App Store receipt from native iOS code:

**iOS Native Code** (`ios/Runner/AppDelegate.swift`):
```swift
import Flutter
import UIKit
import StoreKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let receiptChannel = FlutterMethodChannel(name: "app.aplay/receipt",
                                              binaryMessenger: controller.binaryMessenger)

    receiptChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getAppStoreReceipt" {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
           let receiptData = try? Data(contentsOf: receiptURL) {
          let receiptString = receiptData.base64EncodedString()
          result(receiptString)
        } else {
          result(FlutterError(code: "NO_RECEIPT",
                            message: "No App Store receipt found",
                            details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Flutter Code** (`lib/core/services/purchase_manager.dart`):
```dart
import 'package:flutter/services.dart';

// Add this method to PurchaseManager class
Future<String?> _getAppStoreReceipt() async {
  if (!Platform.isIOS) return null;

  try {
    const platform = MethodChannel('app.aplay/receipt');
    final String receipt = await platform.invokeMethod('getAppStoreReceipt');
    return receipt;
  } catch (e) {
    if (kDebugMode) print('Error getting App Store receipt: $e');
    return null;
  }
}

// Then in _verifyPurchaseWithBackend:
String appStoreReceiptData = receiptData;

if (Platform.isIOS) {
  final fullReceipt = await _getAppStoreReceipt();
  if (fullReceipt != null) {
    appStoreReceiptData = fullReceipt;
    if (kDebugMode) print('Using full App Store receipt: ${fullReceipt.length} chars');
  }
}
```

### Option 2: Temporary Workaround - Skip Backend Verification

For now, to unblock testing, you can temporarily disable backend verification:

```dart
// In _verifyPurchaseWithBackend, add at the start:
if (kDebugMode) {
  print('⚠️ Backend verification temporarily disabled for testing');
  return; // Skip verification during development
}
```

This allows purchases to complete while you implement the platform channel.

### Option 3: Use receipt_validator Package

There's a Flutter package that handles this: `flutter_inapp_purchase` or similar packages that properly extract the receipt.

## Why This Happened

The `in_app_purchase` package **doesn't expose the full App Store receipt** through its API. This is a known limitation. Most production apps either:
1. Use a platform channel to get the receipt (Option 1)
2. Use a different IAP package that includes receipt access
3. Verify purchases using StoreKit 2 (newer iOS only)

## Next Steps

1. **Implement Option 1** (Platform Channel) - This is the most reliable solution
2. **Test with sandbox** purchases after implementation
3. **Verify receipts** are now being accepted by Apple

## References

- Apple Receipt Validation: https://developer.apple.com/documentation/appstorereceipts
- Status Code 21002: https://developer.apple.com/documentation/appstorereceipts/status
- Flutter Platform Channels: https://docs.flutter.dev/platform-integration/platform-channels
