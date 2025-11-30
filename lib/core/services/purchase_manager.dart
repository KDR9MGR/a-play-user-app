import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

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
    return RestoredPurchase(
      productId: details.productID,
      transactionId: details.purchaseID ?? '',
      receiptData: details.verificationData.serverVerificationData,
      transactionDate: details.transactionDate != null 
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(details.transactionDate!))
          : null,
      status: details.status,
    );
  }
}

class PurchaseManager extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Product IDs that match your App Store Connect configuration
  List<String> kProductIds = <String>[
    'SUB7DAYS',      // Weekly Access (trial/weekly)
    'SUB1M',         // Monthly Premium
    'SUB3M',         // 3 Months Bundle (quarterly/biannual)
    'SUBANNU',      // Annual Ultimate
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
      final errorMsg = 'Store not available. This is normal in simulator - test on a physical device.';
      if (kDebugMode) print('PurchaseManager: $errorMsg');
      onPurchaseError?.call(errorMsg);
      return;
    }

    // Check if products are loaded
    if (products.isEmpty) {
      final errorMsg = 'No products loaded. Please wait for initialization to complete.';
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
      await restoreSubscription?.cancel();
      
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

      // Complete the purchase
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

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
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
      
      if (kDebugMode) print('Calling onPurchaseSuccess callback...');
      onPurchaseSuccess?.call(
        purchaseDetails.productID, 
        purchaseDetails.purchaseID ?? '',
        receiptData,
      );
      if (kDebugMode) print('onPurchaseSuccess callback completed');
    } catch (e) {
      if (kDebugMode) print('Error in _handleSuccessfulPurchase: $e');
      _handlePurchaseError('Failed to process successful purchase: $e');
    }
    
    if (kDebugMode) print('=== PurchaseManager: SUCCESSFUL PURCHASE COMPLETE ===');
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