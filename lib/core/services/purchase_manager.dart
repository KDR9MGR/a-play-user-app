import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Class to represent a restored purchase
class RestoredPurchase {
  final String productId;
  final String transactionId;
  final String receiptData;
  final DateTime? transactionDate;
  final PurchaseStatus status;

  RestoredPurchase({
    required this.productId,
    required this.transactionId,
    required this.receiptData,
    this.transactionDate,
    required this.status,
  });

  factory RestoredPurchase.fromPurchaseDetails(PurchaseDetails details) {
    // Helper to safely parse transaction date
    DateTime? parseTransactionDate(String? dateString) {
      if (dateString == null) return null;
      try {
        // Try parsing as ISO8601 date string first (e.g., "2025-12-08 15:13:32")
        return DateTime.tryParse(dateString);
      } catch (e) {
        try {
          // Fallback: try parsing as milliseconds
          final milliseconds = int.tryParse(dateString);
          if (milliseconds != null) {
            return DateTime.fromMillisecondsSinceEpoch(milliseconds);
          }
        } catch (e) {
          // If both fail, return null
        }
        return null;
      }
    }

    return RestoredPurchase(
      productId: details.productID,
      transactionId: details.purchaseID ?? '',
      receiptData: details.verificationData.serverVerificationData,
      transactionDate: parseTransactionDate(details.transactionDate),
      status: details.status,
    );
  }
}

class PurchaseManager extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Product IDs that match your App Store Connect configuration
  List<String> kProductIds = <String>[
    '3SUB', // 3 months
    '1month', // Monthly Premium
    '7day', // 7 Days
    '365day', // 365 Days
  ];
  
  List<ProductDetails> products = [];
  List<String> notFoundIds = [];
  Set<String> purchasedIds = {};  // To track unlocked entitlements
  bool isAvailable = false;
  bool loading = true;

  // Callback functions
  Function(String productId, String transactionId, String receiptData)? onPurchaseSuccess;
  Function(String error)? onPurchaseError;
  Function()? onPurchaseCancelled;
  Function(List<RestoredPurchase> restoredPurchases)? onPurchasesRestored;
  Function()? onRestoreStarted;
  Function()? onRestoreCompleted;
  Function()? onBackendVerificationSuccess; // Called after backend verification succeeds

  PurchaseManager() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () => _subscription.cancel(),
      onError: (Object error) {
        if (kDebugMode) print('Purchase error: $error');
        onPurchaseError?.call(error.toString());
      },
    );
    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    if (kDebugMode) print('PurchaseManager: Initializing store info...');
    
    isAvailable = await _inAppPurchase.isAvailable();
    if (kDebugMode) print('PurchaseManager: Store available: $isAvailable');
    
    if (!isAvailable) {
      loading = false;
      notifyListeners();
      if (kDebugMode) print('PurchaseManager: Store not available - this is normal in simulator');
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      if (kDebugMode) print('PurchaseManager: iOS payment queue delegate set');
    }

    await loadProducts();  // Fetch products
    await restorePurchases();  // Check for existing purchases on init
    loading = false;
    notifyListeners();
    if (kDebugMode) print('PurchaseManager: Initialization completed');
  }

  Future<void> loadProducts() async {
    if (kDebugMode) print('PurchaseManager: Loading products: $kProductIds');
    
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(kProductIds.toSet());
    
    if (response.error != null) {
      if (kDebugMode) print('PurchaseManager: Product query error: ${response.error!.message}');
      onPurchaseError?.call('Failed to load products: ${response.error!.message}');
      return;
    }

    products = response.productDetails;
    notFoundIds = response.notFoundIDs;
    
    if (kDebugMode) {
      print('PurchaseManager: Found ${products.length} products');
      print('PurchaseManager: Not found product IDs: $notFoundIds');
      for (final product in products) {
        print('PurchaseManager: Product - ID: ${product.id}, Title: ${product.title}, Price: ${product.price}');
      }
    }
    
    notifyListeners();
  }

  Future<void> buyProduct(String productId) async {
    if (kDebugMode) print('PurchaseManager: Attempting to buy product: $productId');
    
    // Check if store is available
    if (!isAvailable) {
      const errorMsg = 'Store not available. This is normal in simulator - test on a physical device.';
      if (kDebugMode) print('PurchaseManager: $errorMsg');
      onPurchaseError?.call(errorMsg);
      return;
    }

    // Check if products are loaded
    if (products.isEmpty) {
      const errorMsg = 'No products loaded. Please wait for initialization to complete.';
      if (kDebugMode) print('PurchaseManager: $errorMsg');
      onPurchaseError?.call(errorMsg);
      return;
    }

    // Check if the specific product is available
    ProductDetails? productDetails;
    try {
      productDetails = products.firstWhere(
        (product) => product.id == productId,
      );
    } catch (e) {
      final errorMsg = 'Product not found: $productId. Available products: ${products.map((p) => p.id).join(', ')}. Not found IDs: ${notFoundIds.join(', ')}';
      if (kDebugMode) print('PurchaseManager: $errorMsg');
      onPurchaseError?.call(errorMsg);
      return;
    }

    // Verify product details are valid
    if (productDetails.id.isEmpty) {
      final errorMsg = 'Invalid product details for: $productId';
      if (kDebugMode) print('PurchaseManager: $errorMsg');
      onPurchaseError?.call(errorMsg);
      return;
    }

    if (kDebugMode) {
      print('PurchaseManager: Product found - ID: ${productDetails.id}, Title: ${productDetails.title}, Price: ${productDetails.price}');
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    try {
      // For subscriptions, use buyNonConsumable
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      if (!success) {
        final errorMsg = 'Failed to initiate purchase for: $productId';
        if (kDebugMode) print('PurchaseManager: $errorMsg');
        onPurchaseError?.call(errorMsg);
      } else {
        if (kDebugMode) print('PurchaseManager: Purchase initiated successfully for: $productId');
      }
    } catch (e) {
      final errorMsg = 'Purchase failed for $productId: $e';
      if (kDebugMode) print('PurchaseManager: $errorMsg');
      onPurchaseError?.call(errorMsg);
    }
  }

  Future<void> restorePurchases() async {
    if (kDebugMode) print('PurchaseManager: Starting restore purchases...');
    
    try {
      onRestoreStarted?.call();
      
      // Track restored purchases
      final List<RestoredPurchase> restoredPurchases = [];
      
      // Set up a temporary listener to capture restored purchases
      StreamSubscription<List<PurchaseDetails>>? restoreSubscription;
      
      restoreSubscription = _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
        for (final purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.restored) {
            if (kDebugMode) print('PurchaseManager: Found restored purchase: ${purchaseDetails.productID}');
            restoredPurchases.add(RestoredPurchase.fromPurchaseDetails(purchaseDetails));
            
            // Complete the restored purchase
            if (purchaseDetails.pendingCompletePurchase) {
              _inAppPurchase.completePurchase(purchaseDetails);
            }
          }
        }
      });
      
      // Initiate the restore
      await _inAppPurchase.restorePurchases();
      
      // Wait a bit for all restored purchases to be processed
      await Future.delayed(const Duration(seconds: 2));
      
      // Cancel the temporary subscription
      await restoreSubscription.cancel();
      
      if (kDebugMode) print('PurchaseManager: Restore completed. Found ${restoredPurchases.length} purchases');
      
      // Notify about restored purchases
      if (restoredPurchases.isNotEmpty) {
        onPurchasesRestored?.call(restoredPurchases);
      }
      
      onRestoreCompleted?.call();
      
    } catch (e) {
      if (kDebugMode) print('PurchaseManager: Restore purchases error: $e');
      onPurchaseError?.call('Failed to restore purchases: $e');
      onRestoreCompleted?.call();
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    if (kDebugMode) print('=== PurchaseManager: PURCHASE UPDATE RECEIVED ===');
    if (kDebugMode) print('Number of purchase updates: ${purchaseDetailsList.length}');

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (kDebugMode) print('Processing purchase update - Status: ${purchaseDetails.status}, Product: ${purchaseDetails.productID}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          if (kDebugMode) print('PurchaseManager: Purchase pending: ${purchaseDetails.productID}');
          break;
        case PurchaseStatus.purchased:
          if (kDebugMode) print('PurchaseManager: Purchase completed, processing...');
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          if (kDebugMode) print('PurchaseManager: Purchase error: ${purchaseDetails.error?.message}');
          _handlePurchaseError(purchaseDetails.error?.message ?? 'Unknown error');
          break;
        case PurchaseStatus.canceled:
          if (kDebugMode) print('PurchaseManager: Purchase cancelled: ${purchaseDetails.productID}');
          onPurchaseCancelled?.call();
          break;
        case PurchaseStatus.restored:
          if (kDebugMode) print('PurchaseManager: Purchase restored, processing...');
          _handleSuccessfulPurchase(purchaseDetails);
          break;
      }

      // Complete the purchase AFTER backend verification attempt
      if (purchaseDetails.pendingCompletePurchase) {
        if (kDebugMode) print('PurchaseManager: Completing purchase transaction...');
        try {
          _inAppPurchase.completePurchase(purchaseDetails);
          if (kDebugMode) print('PurchaseManager: Purchase transaction completed successfully');
        } catch (e) {
          if (kDebugMode) print('PurchaseManager: Error completing purchase: $e');
        }
      } else {
        if (kDebugMode) print('PurchaseManager: No pending completion required');
      }
    }

    if (kDebugMode) print('=== PurchaseManager: PURCHASE UPDATE PROCESSING COMPLETE ===');
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    if (kDebugMode) print('=== PurchaseManager: SUCCESSFUL PURCHASE ===');
    if (kDebugMode) print('Product ID: ${purchaseDetails.productID}');
    if (kDebugMode) print('Purchase ID: ${purchaseDetails.purchaseID}');
    if (kDebugMode) print('Transaction Date: ${purchaseDetails.transactionDate}');
    if (kDebugMode) print('Status: ${purchaseDetails.status}');

    try {
      purchasedIds.add(purchaseDetails.productID);
      notifyListeners();

      // Pass server verification data (base64) for backend validation
      final String receiptData = purchaseDetails.verificationData.serverVerificationData;
      if (kDebugMode) print('Receipt data length: ${receiptData.length}');

      // CRITICAL: Always call success callback first to ensure UI updates
      // Backend verification can fail due to network issues, but purchase is already successful
      if (kDebugMode) print('Calling onPurchaseSuccess callback...');
      onPurchaseSuccess?.call(
        purchaseDetails.productID,
        purchaseDetails.purchaseID ?? '',
        receiptData,
      );
      if (kDebugMode) print('onPurchaseSuccess callback completed');

      // Verify purchase with Supabase backend (best effort)
      // If this fails, the purchase is still valid - backend can be updated later
      try {
        await _verifyPurchaseWithBackend(purchaseDetails, receiptData);
      } catch (e) {
        if (kDebugMode) print('⚠️ Backend verification failed (non-fatal): $e');
        // Note: Purchase is still successful. Backend verification can be retried later.
        // The success callback already executed, so UI will update correctly.
      }
    } catch (e) {
      if (kDebugMode) print('Error in _handleSuccessfulPurchase: $e');
      // Only call error if success callback itself failed (not backend verification)
      _handlePurchaseError('Failed to process successful purchase: $e');
    }

    if (kDebugMode) print('=== PurchaseManager: SUCCESSFUL PURCHASE COMPLETE ===');
  }

  /// Get the full App Store receipt from the app bundle (iOS only)
  /// This is required for subscription verification with Apple
  Future<String?> _getAppStoreReceipt() async {
    if (!Platform.isIOS) return null;

    try {
      const platform = MethodChannel('app.aplay/receipt');
      final String receipt = await platform.invokeMethod('getAppStoreReceipt');

      if (kDebugMode) print('PurchaseManager: Retrieved full App Store receipt (${receipt.length} chars)');
      return receipt;
    } on PlatformException catch (e) {
      if (kDebugMode) print('PurchaseManager: Platform exception getting receipt: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      if (kDebugMode) print('PurchaseManager: Error getting App Store receipt: $e');
      return null;
    }
  }

  /// Verify purchase with Supabase Edge Function
  Future<void> _verifyPurchaseWithBackend(PurchaseDetails purchase, String receiptData) async {
    if (kDebugMode) print('PurchaseManager: Starting backend verification...');

    try {
      // Get current Supabase user
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated - cannot verify purchase');
      }

      if (kDebugMode) print('PurchaseManager: User ID: ${user.id}');

      // CRITICAL: For iOS, we need the FULL App Store receipt from the app bundle
      // The purchase details receipt is not sufficient for subscription verification
      String finalReceiptData = receiptData;

      if (Platform.isIOS) {
        final appStoreReceipt = await _getAppStoreReceipt();

        if (appStoreReceipt != null) {
          finalReceiptData = appStoreReceipt;
          if (kDebugMode) {
            print('PurchaseManager: Using full App Store receipt');
            print('PurchaseManager: Receipt length: ${finalReceiptData.length} characters');
          }
        } else {
          if (kDebugMode) print('⚠️ PurchaseManager: Could not get full receipt, using purchase receipt (may fail)');
        }
      }

      // Determine if this is a sandbox environment
      // In production builds, this should be false
      const isSandbox = bool.fromEnvironment('SANDBOX_MODE', defaultValue: kDebugMode);

      if (kDebugMode) print('PurchaseManager: Sandbox mode: $isSandbox');
      if (kDebugMode) print('PurchaseManager: Calling verify-apple-sub Edge Function...');

      // Call Supabase Edge Function to verify with Apple
      final response = await supabase.functions.invoke(
        'verify-apple-sub',
        body: {
          'receiptData': finalReceiptData,
          'userId': user.id,
          'sandbox': isSandbox,
        },
      );

      if (kDebugMode) print('PurchaseManager: Edge Function response status: ${response.status}');

      if (response.status != 200) {
        throw Exception('Edge Function returned status ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      if (kDebugMode) print('PurchaseManager: Response data: $data');

      // Check if verification succeeded
      if (data['success'] != true || data['isSubscribed'] != true) {
        final errorCode = data['errorCode'] ?? 'unknown_error';
        final appleStatus = data['appleStatus'];
        throw Exception('Verification failed: $errorCode (Apple status: $appleStatus)');
      }

      if (kDebugMode) {
        print('✅ PurchaseManager: Backend verification SUCCESS');
        print('   Product: ${data['productId']}');
        print('   Expires: ${data['expiry']}');
        print('   Status: ${data['status']}');
      }

      // Notify that backend verification succeeded
      // This allows the app to refresh subscription status
      onBackendVerificationSuccess?.call();

    } catch (e) {
      if (kDebugMode) print('❌ PurchaseManager: Backend verification FAILED: $e');
      // Rethrow to caller - will be caught and logged in _handleSuccessfulPurchase
      // Purchase is still successful, this is just for our records
      // User support can manually verify if needed
      rethrow;
    }
  }

  void _handlePurchaseError(String error) {
    if (kDebugMode) print('PurchaseManager: Purchase error: $error');
    onPurchaseError?.call(error);
  }

  bool isPurchased(String productId) {
    return purchasedIds.contains(productId);
  }

  ProductDetails? getProduct(String productId) {
    try {
      return products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Check if a specific product is available for purchase
  bool isProductAvailable(String productId) {
    return products.any((product) => product.id == productId);
  }

  /// Get detailed status information for debugging
  Map<String, dynamic> getDebugInfo() {
    return {
      'isAvailable': isAvailable,
      'loading': loading,
      'productsCount': products.length,
      'availableProductIds': products.map((p) => p.id).toList(),
      'notFoundIds': notFoundIds,
      'purchasedIds': purchasedIds.toList(),
      'expectedProductIds': kProductIds,
    };
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }
}

// Payment queue delegate for iOS
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    if (kDebugMode) print('PurchaseManager: Should continue transaction: ${transaction.transactionIdentifier}');
    return true;  // Allow all transactions; customize as needed
  }

  @override
  bool shouldShowPriceConsent() {
    if (kDebugMode) print('PurchaseManager: Should show price consent');
    return false;  // Or true if you want to prompt for price changes
  }
}
