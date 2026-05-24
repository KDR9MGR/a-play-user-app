import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/subscription/service/subscription_sync_service.dart';

/// Clean, simple IAP Service for iOS subscriptions
/// Handles all StoreKit interactions for A-Play subscriptions
class IAPService {
  static final IAPService instance = IAPService._internal();
  factory IAPService() => instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Product IDs matching StoreKit configuration
  static const String weeklyProduct = '7day';
  static const String monthlyProduct = '1month';
  static const String quarterlyProduct = '3SUB';
  static const String annualProduct = '365day';

  // All subscription product IDs
  static const List<String> productIds = [
    weeklyProduct,
    monthlyProduct,
    quarterlyProduct,
    annualProduct,
  ];

  // State
  bool _isAvailable = false;
  bool _isInitialized = false;
  List<ProductDetails> _products = [];

  // Callbacks
  void Function(ProductDetails product)? onPurchaseSuccess;
  void Function(String error)? onPurchaseError;
  void Function()? onPurchaseCancelled;

  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;
  List<ProductDetails> get products => _products;

  /// Initialize the IAP service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('IAPService: Already initialized');
      return;
    }

    debugPrint('IAPService: Initializing...');

    // Check if IAP is available
    _isAvailable = await _iap.isAvailable();
    debugPrint('IAPService: Store available: $_isAvailable');

    if (!_isAvailable) {
      debugPrint('IAPService: Store not available (normal in simulator)');
      _isInitialized = true;
      return;
    }

    // Set up iOS payment queue delegate
    if (!kIsWeb && Platform.isIOS) {
      final iosPlatform = _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatform.setDelegate(PaymentQueueDelegate());
      debugPrint('IAPService: iOS payment queue delegate set');
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => debugPrint('IAPService: Purchase stream done'),
      onError: (error) {
        debugPrint('IAPService: Purchase stream error: $error');
        onPurchaseError?.call(error.toString());
      },
    );

    // Load products
    await _loadProducts();

    // CRITICAL: Check for existing subscriptions on startup
    // This syncs StoreKit state with the app
    debugPrint('IAPService: Checking for existing subscriptions...');
    await _checkExistingSubscriptions();

    _isInitialized = true;
    debugPrint('IAPService: Initialization complete');
  }

  /// Check for existing subscriptions in StoreKit
  /// This is called on app startup to sync existing subscriptions
  Future<void> _checkExistingSubscriptions() async {
    if (kIsWeb || !Platform.isIOS) return;

    try {
      debugPrint('IAPService: Querying past purchases...');

      // Query past purchases to find active subscriptions
      await _iap.restorePurchases();

      debugPrint('IAPService: Past purchases check complete');
    } catch (e) {
      debugPrint('IAPService: Error checking existing subscriptions: $e');
    }
  }

  /// Load subscription products from the store
  Future<void> _loadProducts() async {
    debugPrint('IAPService: Loading products...');

    final response = await _iap.queryProductDetails(productIds.toSet());

    if (response.error != null) {
      debugPrint('IAPService: Error loading products: ${response.error!.message}');
      return;
    }

    _products = response.productDetails;

    debugPrint('IAPService: Loaded ${_products.length} products');
    for (var product in _products) {
      debugPrint('IAPService: - ${product.id}: ${product.title} (${product.price})');
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAPService: Products not found: ${response.notFoundIDs}');
    }
  }

  /// Purchase a subscription
  Future<void> purchaseSubscription(String productId) async {
    debugPrint('IAPService: Initiating purchase for: $productId');

    if (!_isAvailable) {
      final error = 'Store not available. Please try on a physical device.';
      debugPrint('IAPService: $error');
      onPurchaseError?.call(error);
      return;
    }

    // Find the product
    final product = _products.where((p) => p.id == productId).firstOrNull;
    if (product == null) {
      final error = 'Product not found: $productId';
      debugPrint('IAPService: $error');
      onPurchaseError?.call(error);
      return;
    }

    debugPrint('IAPService: Purchasing ${product.title} for ${product.price}');

    // Create purchase param
    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      // Initiate purchase
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      if (success) {
        debugPrint('IAPService: ✓ Purchase initiated');
        debugPrint('IAPService: Waiting for user to confirm payment...');
      } else {
        debugPrint('IAPService: ✗ Failed to initiate purchase');
        onPurchaseError?.call('Failed to start purchase');
      }
    } catch (e) {
      debugPrint('IAPService: Purchase exception: $e');
      onPurchaseError?.call(e.toString());
    }
  }

  /// Handle purchase updates from the store
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    debugPrint('IAPService: ═══ Purchase Update ═══');
    debugPrint('IAPService: Updates count: ${purchaseDetailsList.length}');

    for (var purchaseDetails in purchaseDetailsList) {
      debugPrint('IAPService: Product: ${purchaseDetails.productID}');
      debugPrint('IAPService: Status: ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePending(purchaseDetails);
          break;

        case PurchaseStatus.purchased:
          _handlePurchased(purchaseDetails);
          break;

        case PurchaseStatus.error:
          _handleError(purchaseDetails);
          break;

        case PurchaseStatus.canceled:
          _handleCancelled(purchaseDetails);
          break;

        case PurchaseStatus.restored:
          _handleRestored(purchaseDetails);
          break;
      }

      // Complete the purchase if needed
      if (purchaseDetails.pendingCompletePurchase) {
        debugPrint('IAPService: Completing transaction...');
        _iap.completePurchase(purchaseDetails);
      }
    }

    debugPrint('IAPService: ═══════════════════════');
  }

  void _handlePending(PurchaseDetails details) {
    debugPrint('IAPService: ⏳ Purchase PENDING');
    debugPrint('IAPService: → Look for payment confirmation dialog');
    debugPrint('IAPService: → Tap [Buy] to complete purchase');
  }

  void _handlePurchased(PurchaseDetails details) {
    debugPrint('IAPService: ✓ Purchase SUCCESSFUL!');
    debugPrint('IAPService: Product: ${details.productID}');
    debugPrint('IAPService: Transaction: ${details.purchaseID}');

    // Find the product details
    final product = _products.where((p) => p.id == details.productID).firstOrNull;
    if (product != null) {
      onPurchaseSuccess?.call(product);
    }
  }

  void _handleError(PurchaseDetails details) {
    debugPrint('IAPService: ✗ Purchase ERROR');
    debugPrint('IAPService: ${details.error?.message ?? "Unknown error"}');
    onPurchaseError?.call(details.error?.message ?? 'Purchase failed');
  }

  void _handleCancelled(PurchaseDetails details) {
    debugPrint('IAPService: ✗ Purchase CANCELLED by user');
    onPurchaseCancelled?.call();
  }

  void _handleRestored(PurchaseDetails details) async {
    debugPrint('IAPService: ↻ Purchase RESTORED');
    debugPrint('IAPService: Product: ${details.productID}');

    // CRITICAL: Auto-sync restored purchase to database
    // This handles the case where user has subscription in StoreKit but not in database
    try {
      debugPrint('IAPService: Auto-syncing restored purchase to database...');
      final syncService = SubscriptionSyncService();
      await syncService.syncFromStoreKit(details.productID);
      debugPrint('IAPService: ✓ Restored purchase synced to database');
    } catch (e) {
      debugPrint('IAPService: ✗ Failed to sync restored purchase: $e');
      // Don't fail silently - this is critical for subscription sync
    }

    // Also trigger callback if UI is listening
    final product = _products.where((p) => p.id == details.productID).firstOrNull;
    if (product != null) {
      onPurchaseSuccess?.call(product);
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    debugPrint('IAPService: Restoring purchases...');

    if (!_isAvailable) {
      onPurchaseError?.call('Store not available');
      return;
    }

    try {
      await _iap.restorePurchases();
      debugPrint('IAPService: Restore initiated');
    } catch (e) {
      debugPrint('IAPService: Restore error: $e');
      onPurchaseError?.call('Failed to restore purchases');
    }
  }

  /// Get product details by ID
  ProductDetails? getProduct(String productId) {
    return _products.where((p) => p.id == productId).firstOrNull;
  }

  /// Check current StoreKit transactions and sync with database
  /// Call this when user views subscription screen to detect cancellations
  Future<Map<String, dynamic>> checkActiveSubscriptions() async {
    debugPrint('IAPService: Checking active StoreKit transactions...');

    if (kIsWeb || !Platform.isIOS) {
      return {'hasActive': false, 'products': []};
    }

    try {
      // Get all transactions from StoreKit
      final transactions = await SKPaymentQueueWrapper().transactions();
      debugPrint('IAPService: Found ${transactions.length} StoreKit transactions');

      final activeProducts = <String>[];

      for (var transaction in transactions) {
        debugPrint('IAPService: Transaction ${transaction.transactionIdentifier}');
        debugPrint('IAPService:   State: ${transaction.transactionState}');
        debugPrint('IAPService:   Product: ${transaction.payment.productIdentifier}');

        // Check if this is an active subscription transaction
        if (transaction.transactionState == SKPaymentTransactionStateWrapper.purchased ||
            transaction.transactionState == SKPaymentTransactionStateWrapper.restored) {
          activeProducts.add(transaction.payment.productIdentifier);
        }
      }

      debugPrint('IAPService: Active subscription products: $activeProducts');

      return {
        'hasActive': activeProducts.isNotEmpty,
        'products': activeProducts,
      };
    } catch (e) {
      debugPrint('IAPService: Error checking transactions: $e');
      return {'hasActive': false, 'products': []};
    }
  }

  /// Sync database with current StoreKit state
  /// Detects and handles cancelled subscriptions
  Future<void> syncDatabaseWithStoreKit() async {
    debugPrint('IAPService: Syncing database with StoreKit state...');

    final storeKitState = await checkActiveSubscriptions();
    final hasStoreKitSub = storeKitState['hasActive'] as bool;
    final storeKitProducts = storeKitState['products'] as List<String>;

    final syncService = SubscriptionSyncService();
    final hasDatabaseSub = await syncService.hasActiveSubscription();

    debugPrint('IAPService: StoreKit has subscription: $hasStoreKitSub');
    debugPrint('IAPService: Database has subscription: $hasDatabaseSub');

    // Case 1: Database has subscription but StoreKit doesn't (CANCELLED)
    if (hasDatabaseSub && !hasStoreKitSub) {
      debugPrint('IAPService: ⚠️  SUBSCRIPTION CANCELLED - Updating database...');
      await _cancelDatabaseSubscription();
      return;
    }

    // Case 2: StoreKit has subscription but database doesn't (RESTORE NEEDED)
    if (!hasDatabaseSub && hasStoreKitSub && storeKitProducts.isNotEmpty) {
      debugPrint('IAPService: ⚠️  SUBSCRIPTION FOUND IN STOREKIT - Syncing to database...');
      await syncService.syncFromStoreKit(storeKitProducts.first);
      return;
    }

    debugPrint('IAPService: ✓ Database and StoreKit are in sync');
  }

  /// Cancel subscription in database when StoreKit shows it's cancelled
  Future<void> _cancelDatabaseSubscription() async {
    try {
      final syncService = SubscriptionSyncService();
      final activeSub = await syncService.getActiveSubscription();

      if (activeSub == null) {
        debugPrint('IAPService: No active subscription to cancel');
        return;
      }

      final subscriptionId = activeSub['subscription_id'];
      if (subscriptionId == null) {
        debugPrint('IAPService: No subscription ID found');
        return;
      }

      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        debugPrint('IAPService: No user logged in');
        return;
      }

      // Update subscription status to cancelled
      await supabase.from('user_subscriptions').update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', subscriptionId).eq('user_id', userId);

      // Update profile
      await supabase.from('profiles').update({
        'is_subscribed': false,
        'subscription_tier': 'Free',
        'subscription_expires_at': null,
        'current_tier': 'Free',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      debugPrint('IAPService: ✓ Subscription cancelled in database');
    } catch (e) {
      debugPrint('IAPService: ✗ Error cancelling subscription: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    debugPrint('IAPService: Disposing...');
    _subscription?.cancel();

    if (Platform.isIOS) {
      final iosPlatform = _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatform.setDelegate(null);
    }
  }
}

/// iOS Payment Queue Delegate
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    debugPrint('PaymentQueueDelegate: Continue transaction: ${transaction.transactionIdentifier}');
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    debugPrint('PaymentQueueDelegate: Show price consent: false');
    return false;
  }
}
