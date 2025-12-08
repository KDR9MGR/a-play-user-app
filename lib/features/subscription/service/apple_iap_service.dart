import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/services/purchase_manager.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// Enhanced error types for Apple IAP
enum AppleIAPErrorType {
  notAvailable,
  productNotFound,
  purchaseFailed,
  userCancelled,
  networkError,
  receiptValidationFailed,
  unknownError,
  platformNotSupported,
  storeNotAvailable,
  paymentNotAllowed,
  invalidProductId,
  restoreFailed,
}

// Enhanced error class for Apple IAP
class AppleIAPError {
  final AppleIAPErrorType type;
  final String message;
  final String? originalError;
  final String? userFriendlyMessage;

  AppleIAPError({
    required this.type,
    required this.message,
    this.originalError,
    this.userFriendlyMessage,
  });

  String get displayMessage => userFriendlyMessage ?? message;

  static AppleIAPError fromException(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('cancelled') || errorString.contains('user cancelled')) {
      return AppleIAPError(
        type: AppleIAPErrorType.userCancelled,
        message: 'Purchase was cancelled by user',
        originalError: error.toString(),
        userFriendlyMessage: 'Purchase cancelled',
      );
    } else if (errorString.contains('not available') || errorString.contains('store not available')) {
      return AppleIAPError(
        type: AppleIAPErrorType.storeNotAvailable,
        message: 'App Store not available',
        originalError: error.toString(),
        userFriendlyMessage: 'App Store is not available. Please try again later.',
      );
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return AppleIAPError(
        type: AppleIAPErrorType.networkError,
        message: 'Network error during purchase',
        originalError: error.toString(),
        userFriendlyMessage: 'Network error. Please check your internet connection and try again.',
      );
    } else if (errorString.contains('product') && errorString.contains('not found')) {
      return AppleIAPError(
        type: AppleIAPErrorType.productNotFound,
        message: 'Product not found in App Store',
        originalError: error.toString(),
        userFriendlyMessage: 'This subscription plan is not available. Please try a different plan.',
      );
    } else if (errorString.contains('payment not allowed') || errorString.contains('restricted')) {
      return AppleIAPError(
        type: AppleIAPErrorType.paymentNotAllowed,
        message: 'Payment not allowed',
        originalError: error.toString(),
        userFriendlyMessage: 'Purchases are restricted on this device. Please check your device settings.',
      );
    } else if (errorString.contains('receipt') || errorString.contains('validation')) {
      return AppleIAPError(
        type: AppleIAPErrorType.receiptValidationFailed,
        message: 'Receipt validation failed',
        originalError: error.toString(),
        userFriendlyMessage: 'Purchase verification failed. Please contact support if the issue persists.',
      );
    } else {
      return AppleIAPError(
        type: AppleIAPErrorType.unknownError,
        message: 'Unknown error occurred',
        originalError: error.toString(),
        userFriendlyMessage: 'An unexpected error occurred. Please try again or contact support.',
      );
    }
  }
}

class AppleIAPService {
  late PurchaseManager _purchaseManager;
  
  // Product IDs that match your App Store Connect configuration
  static const Map<String, String> _productIds = {
    'trial_plan': 'SUB7DAY',       // Weekly Access (7 days) - Free trial maps to weekly for Apple
    'weekly_plan': 'SUB7DAY',      // Weekly Access
    'monthly_plan': 'SUBM',         // Monthly Premium
    'quarterly_plan': 'SUBM3',      // 3 Months Bundle
    'biannual_plan': 'SUBM3',       // Using 3 months as closest option (no 6-month in App Store)
    'annual_plan': 'SUBAU',         // Annual Ultimate (matches App Store Connect)
  };

  // Reverse mapping for converting Apple product IDs back to plan IDs
  static const Map<String, String> _reversePlanMapping = {
    'SUB7DAY': 'weekly_plan',       // Default to weekly for 7-day product
    'SUBM': 'monthly_plan',
    'SUBM3': 'quarterly_plan',
    'SUBAU': 'annual_plan',
  };

  // Callback functions with enhanced error handling
  Function(String planId, String transactionId, String receiptData)? onPurchaseSuccess;
  Function(AppleIAPError error)? onPurchaseError;
  Function()? onPurchaseCancelled;
  Function(List<RestoredPurchase> restoredPurchases)? onPurchasesRestored;
  Function()? onRestoreStarted;
  Function()? onRestoreCompleted;

  AppleIAPService() {
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    if (!Platform.isIOS) {
      debugPrint('Apple IAP: Not on iOS platform, skipping initialization');
      return;
    }

    try {
      debugPrint('Apple IAP: Initializing with PurchaseManager...');
      
      // Initialize the PurchaseManager
      _purchaseManager = PurchaseManager();
      
      // Set up callbacks with enhanced error handling
      _purchaseManager.onPurchaseSuccess = (productId, transactionId, receiptData) {
        // Convert product ID back to plan ID
        final planId = getPlanIdForProduct(productId);
        if (planId != null) {
          onPurchaseSuccess?.call(planId, transactionId, receiptData);
        } else {
          final error = AppleIAPError(
            type: AppleIAPErrorType.invalidProductId,
            message: 'Unknown product ID: $productId',
            userFriendlyMessage: 'Invalid subscription plan. Please try again.',
          );
          onPurchaseError?.call(error);
        }
      };
      
      _purchaseManager.onPurchaseError = (error) {
        final appleError = AppleIAPError.fromException(error);
        onPurchaseError?.call(appleError);
      };
      
      _purchaseManager.onPurchaseCancelled = () {
        onPurchaseCancelled?.call();
      };
      
      // Set up restore callbacks
      _purchaseManager.onPurchasesRestored = (restoredPurchases) {
        onPurchasesRestored?.call(restoredPurchases);
      };
      
      _purchaseManager.onRestoreStarted = () {
        onRestoreStarted?.call();
      };
      
      _purchaseManager.onRestoreCompleted = () {
        onRestoreCompleted?.call();
      };
      
      debugPrint('Apple IAP: Initialization completed successfully with PurchaseManager');
    } catch (e) {
      debugPrint('Apple IAP: Initialization failed: $e');
      final error = AppleIAPError.fromException(e);
      onPurchaseError?.call(error);
    }
  }

  Future<bool> isAvailable() async {
    return _purchaseManager.isAvailable;
  }

  Future<List<ProductDetails>> getProducts() async {
    if (!Platform.isIOS) {
      debugPrint('Apple IAP: Not on iOS, returning empty product list');
      throw AppleIAPError(
        type: AppleIAPErrorType.platformNotSupported,
        message: 'Apple IAP is only available on iOS',
        userFriendlyMessage: 'In-app purchases are not supported on this platform.',
      );
    }

    try {
      debugPrint('Apple IAP: Getting products from PurchaseManager...');
      
      // Wait for PurchaseManager to finish loading if still loading
      while (_purchaseManager.loading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      if (!_purchaseManager.isAvailable) {
        debugPrint('Apple IAP: Store not available. This is normal in simulator.');
        throw AppleIAPError(
          type: AppleIAPErrorType.storeNotAvailable,
          message: 'In-App Purchase not available. This is normal in simulator.',
          userFriendlyMessage: 'App Store is not available. Please try again later.',
        );
      }

      debugPrint('Apple IAP: Found ${_purchaseManager.products.length} products');
      debugPrint('Apple IAP: Invalid product IDs: ${_purchaseManager.notFoundIds}');
      
      for (final product in _purchaseManager.products) {
        debugPrint('Apple IAP: Product - ID: ${product.id}, Title: ${product.title}, Price: ${product.price}');
      }

      return _purchaseManager.products;
    } catch (e) {
      debugPrint('Apple IAP: getProducts failed: $e');
      if (e is AppleIAPError) {
        rethrow;
      }
      throw AppleIAPError.fromException(e);
    }
  }

  Future<void> purchaseSubscription(String planId) async {
    if (!Platform.isIOS) {
      throw AppleIAPError(
        type: AppleIAPErrorType.platformNotSupported,
        message: 'Apple IAP is only available on iOS',
        userFriendlyMessage: 'In-app purchases are not supported on this platform.',
      );
    }

    final String? productId = _productIds[planId];
    if (productId == null) {
      throw AppleIAPError(
        type: AppleIAPErrorType.productNotFound,
        message: 'Product ID not found for plan: $planId',
        userFriendlyMessage: 'This subscription plan is not available. Please try a different plan.',
      );
    }

    try {
      debugPrint('Apple IAP: Initiating purchase for plan: $planId, product: $productId');
      
      // Check if store is available before attempting purchase
      if (!_purchaseManager.isAvailable) {
        throw AppleIAPError(
          type: AppleIAPErrorType.storeNotAvailable,
          message: 'App Store not available',
          userFriendlyMessage: 'App Store is not available. Please try again later.',
        );
      }
      
      await _purchaseManager.buyProduct(productId);
    } catch (e) {
      debugPrint('Apple IAP: Purchase error: $e');
      if (e is AppleIAPError) {
        rethrow;
      }
      throw AppleIAPError.fromException(e);
    }
  }

  Future<void> restorePurchases() async {
    if (!Platform.isIOS) {
      throw AppleIAPError(
        type: AppleIAPErrorType.platformNotSupported,
        message: 'Apple IAP is only available on iOS',
        userFriendlyMessage: 'Purchase restoration is not supported on this platform.',
      );
    }

    try {
      debugPrint('Apple IAP: Restoring purchases via PurchaseManager...');
      
      // Check if store is available before attempting restore
      if (!_purchaseManager.isAvailable) {
        throw AppleIAPError(
          type: AppleIAPErrorType.storeNotAvailable,
          message: 'App Store not available',
          userFriendlyMessage: 'App Store is not available. Please try again later.',
        );
      }
      
      await _purchaseManager.restorePurchases();
    } catch (e) {
      debugPrint('Apple IAP: Restore purchases failed: $e');
      if (e is AppleIAPError) {
        rethrow;
      }
      throw AppleIAPError(
        type: AppleIAPErrorType.restoreFailed,
        message: 'Failed to restore purchases: $e',
        originalError: e.toString(),
        userFriendlyMessage: 'Failed to restore purchases. Please try again or contact support.',
      );
    }
  }

  String? getProductIdForPlan(String planId) {
    return _productIds[planId];
  }

  /// Get plan ID from Apple product ID
  static String? getPlanIdFromProductId(String productId) {
    return _reversePlanMapping[productId];
  }

  /// Get Apple product ID from plan ID
  static String? getProductIdFromPlanId(String planId) {
    return _productIds[planId];
  }

  String? getPlanIdForProduct(String productId) {
    for (final entry in _productIds.entries) {
      if (entry.value == productId) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get debug information from PurchaseManager for troubleshooting
  Map<String, dynamic> getDebugInfo() {
    return _purchaseManager.getDebugInfo();
  }

  void dispose() {
    _purchaseManager.dispose();
  }
}