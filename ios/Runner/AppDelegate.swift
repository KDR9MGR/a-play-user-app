import Flutter
import UIKit
import StoreKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Initialize Google Maps SDK
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String {
      GMSServices.provideAPIKey(mapsApiKey)
      print("✅ AppDelegate: Google Maps initialized successfully")
    } else {
      print("⚠️ AppDelegate: Google Maps API key not found in Info.plist")
    }

    // Set up platform channel for App Store receipt
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let receiptChannel = FlutterMethodChannel(name: "app.aplay/receipt",
                                              binaryMessenger: controller.binaryMessenger)

    receiptChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

      if call.method == "getAppStoreReceipt" {
        // Get the App Store receipt from the app bundle
        if let receiptURL = Bundle.main.appStoreReceiptURL {
          do {
            let receiptData = try Data(contentsOf: receiptURL)
            let receiptString = receiptData.base64EncodedString()

            print("📱 AppDelegate: App Store receipt retrieved successfully")
            print("📱 AppDelegate: Receipt length: \(receiptString.count) characters")

            result(receiptString)
          } catch {
            print("❌ AppDelegate: Error reading receipt: \(error.localizedDescription)")
            result(FlutterError(code: "RECEIPT_READ_ERROR",
                              message: "Failed to read App Store receipt: \(error.localizedDescription)",
                              details: nil))
          }
        } else {
          print("❌ AppDelegate: No App Store receipt URL found")
          result(FlutterError(code: "NO_RECEIPT",
                            message: "No App Store receipt found. This is normal in simulator or if no purchases have been made.",
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
