import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/subscription/service/subscription_sync_service.dart';
import '../../features/subscription/service/subscription_service.dart';
import 'iap_logger.dart';

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
  final Map<String, Timer> _pendingTimers = {}; // Track pending purchases

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
    IAPLogger.log('init_start');

    // Check if IAP is available
    _isAvailable = await _iap.isAvailable();
    debugPrint('IAPService: Store available: $_isAvailable');

    if (!_isAvailable) {
      debugPrint('IAPService: Store not available (normal in simulator)');
      IAPLogger.log('init_store_unavailable', level: 'warn');
      _isInitialized = true;
      return;
    }
    IAPLogger.log('init_store_available');

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

    // NOTE: We deliberately do NOT call restorePurchases() here. Doing so on every
    // app launch can trigger the App Store sign-in prompt at startup (Apple review
    // rejection risk, Guideline 5.1.1) and floods the purchase stream with restored
    // events on every cold start. Existing subscription state is instead detected
    // via syncDatabaseWithStoreKit() (StoreKit transaction query, not restore), and
    // a full restore only runs when the user explicitly taps "Restore Purchases".

    _isInitialized = true;
    debugPrint('IAPService: Initialization complete');
  }

  /// Re-queries the store for products without re-running the rest of
  /// initialize() (purchase stream listener, payment queue delegate). Needed
  /// because initialize() is a one-shot guarded by _isInitialized: once the
  /// first product query fails (e.g. a transient "StoreKit: Failed to get
  /// response from platform" network blip), _isInitialized is still set to
  /// true, so every subsequent call to initialize() - including from the
  /// subscription screen's "Retry" button - was a silent no-op that never
  /// actually re-queried StoreKit. The only way to recover used to be force-
  /// quitting the whole app. This is what "Retry" should actually call.
  Future<void> reloadProducts() async {
    if (!_isAvailable) {
      debugPrint('IAPService: Cannot reload products, store not available');
      return;
    }
    await _loadProducts();
  }

  /// Load subscription products from the store
  Future<void> _loadProducts() async {
    debugPrint('IAPService: Loading products...');

    final response = await _iap.queryProductDetails(productIds.toSet());

    if (response.error != null) {
      debugPrint('IAPService: Error loading products: ${response.error!.message}');
      IAPLogger.log(
        'products_query_error',
        level: 'error',
        message: response.error!.message,
        detail: {'code': response.error!.code, 'source': response.error!.source},
      );
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

    // notFoundIDs is the #1 real-world cause of "purchase doesn't work" in
    // production: it means these product IDs aren't in "Ready to Submit"/
    // "Approved" state in App Store Connect (or the Paid Apps Agreement
    // isn't active), so StoreKit won't return them and the buy button never
    // even reaches Apple. Loading 0/4 products is a strong signal of this.
    IAPLogger.log(
      'products_loaded',
      level: response.notFoundIDs.isNotEmpty ? 'warn' : 'info',
      detail: {
        'requested': productIds,
        'loadedIds': _products.map((p) => p.id).toList(),
        'notFoundIds': response.notFoundIDs,
      },
    );
  }

  /// Purchase a subscription
  Future<void> purchaseSubscription(String productId) async {
    debugPrint('IAPService: Initiating purchase for: $productId');
    IAPLogger.log('purchase_initiated', productId: productId);

    if (!_isAvailable) {
      final error = 'Store not available. Please try on a physical device.';
      debugPrint('IAPService: $error');
      IAPLogger.log('purchase_store_unavailable', level: 'error', productId: productId, message: error);
      onPurchaseError?.call(error);
      return;
    }

    // Find the product
    final product = _products.where((p) => p.id == productId).firstOrNull;
    if (product == null) {
      final error = 'Product not found: $productId';
      debugPrint('IAPService: $error');
      IAPLogger.log(
        'purchase_product_not_found',
        level: 'error',
        productId: productId,
        message: error,
        detail: {'loadedIds': _products.map((p) => p.id).toList()},
      );
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
        IAPLogger.log('purchase_buy_call_succeeded', productId: productId);
      } else {
        debugPrint('IAPService: ✗ Failed to initiate purchase');
        IAPLogger.log('purchase_buy_call_failed', level: 'error', productId: productId);
        onPurchaseError?.call('Failed to start purchase');
      }
    } catch (e) {
      debugPrint('IAPService: Purchase exception: $e');
      IAPLogger.log('purchase_buy_call_exception', level: 'error', productId: productId, message: e.toString());
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

      // Complete the purchase if needed. Purchased transactions are the exception:
      // they're only completed after backend receipt verification succeeds (see
      // _handlePurchased), so a crash or verification failure lets StoreKit
      // redeliver the transaction on next launch instead of losing it.
      if (purchaseDetails.pendingCompletePurchase &&
          purchaseDetails.status != PurchaseStatus.purchased) {
        debugPrint('IAPService: Completing transaction...');
        _iap.completePurchase(purchaseDetails);
      }
    }

    debugPrint('IAPService: ═══════════════════════');
  }

  void _handlePending(PurchaseDetails details) {
    debugPrint('IAPService: ⏳ Purchase PENDING');
    IAPLogger.log(
      'purchase_pending',
      level: 'warn',
      productId: details.productID,
      transactionId: details.purchaseID,
    );
    debugPrint('IAPService: → Product: ${details.productID}');
    debugPrint('IAPService: → Purchase ID: ${details.purchaseID}');
    debugPrint('IAPService: → Transaction Date: ${details.transactionDate}');
    debugPrint('IAPService: → Pending Complete: ${details.pendingCompletePurchase}');
    debugPrint('IAPService: ');
    debugPrint('IAPService: 📱 SANDBOX TESTING INSTRUCTIONS:');
    debugPrint('IAPService: 1. Look for the StoreKit payment confirmation dialog');
    debugPrint('IAPService: 2. Tap [Buy] to complete the purchase');
    debugPrint('IAPService: 3. If testing in Sandbox, the purchase should complete within 5-10 seconds');
    debugPrint('IAPService: 4. If stuck, try:');
    debugPrint('IAPService:    - Restart the app');
    debugPrint('IAPService:    - Sign out/in to Sandbox account in Settings');
    debugPrint('IAPService:    - Check Network Connection');
    debugPrint('IAPService: ');

    // NOTE: In Sandbox, pending status can take time to resolve
    // StoreKit will automatically call back with purchased/error status
    // No action needed here - just wait for the status update
  }

  void _handlePurchased(PurchaseDetails details) {
    debugPrint('IAPService: ✓ Purchase SUCCESSFUL, pending receipt verification...');
    debugPrint('IAPService: Product: ${details.productID}');
    debugPrint('IAPService: Transaction: ${details.purchaseID}');
    IAPLogger.log(
      'purchase_purchased',
      productId: details.productID,
      transactionId: details.purchaseID,
      message: 'StoreKit reported purchased, starting backend verification',
    );

    final product = _products.where((p) => p.id == details.productID).firstOrNull;
    if (product == null) {
      debugPrint('IAPService: ✗ Unknown product for purchase: ${details.productID}');
      IAPLogger.log(
        'purchase_unknown_product',
        level: 'error',
        productId: details.productID,
        transactionId: details.purchaseID,
        detail: {'loadedIds': _products.map((p) => p.id).toList()},
      );
      onPurchaseError?.call('Unknown product: ${details.productID}');
      return;
    }

    // Fire-and-forget: verify with Apple via the backend, and only complete the
    // StoreKit transaction (and notify the UI) once that succeeds. Never insert
    // the subscription client-side without a verified receipt.
    _verifyAndCompletePurchase(details, product);
  }

  Future<void> _verifyAndCompletePurchase(PurchaseDetails details, ProductDetails product) async {
    final transactionId = details.purchaseID;
    final receiptData = details.verificationData.serverVerificationData;

    if (transactionId == null || receiptData.isEmpty) {
      debugPrint('IAPService: ✗ Missing transaction ID or receipt data, cannot verify');
      IAPLogger.log(
        'verify_call_skipped_missing_data',
        level: 'error',
        productId: details.productID,
        transactionId: transactionId,
        detail: {'hasTransactionId': transactionId != null, 'receiptDataEmpty': receiptData.isEmpty},
      );
      onPurchaseError?.call('Purchase is missing verification data. Please try again.');
      return;
    }

    IAPLogger.log('verify_call_start', productId: details.productID, transactionId: transactionId);

    try {
      final transactionTimestampMs = int.tryParse(details.transactionDate ?? '');
      await SubscriptionService().verifyAndActivateAppleSubscription(
        productId: details.productID,
        transactionId: transactionId,
        receiptData: receiptData,
        transactionDate: transactionTimestampMs != null
            ? DateTime.fromMillisecondsSinceEpoch(transactionTimestampMs, isUtc: true)
            : null,
      );

      debugPrint('IAPService: ✓ Receipt verified and subscription activated');
      IAPLogger.log('verify_call_success', productId: details.productID, transactionId: transactionId);
      _iap.completePurchase(details);
      onPurchaseSuccess?.call(product);
    } catch (e) {
      debugPrint('IAPService: ✗ Receipt verification failed: $e');
      IAPLogger.log(
        'verify_call_failed',
        level: 'error',
        productId: details.productID,
        transactionId: transactionId,
        message: e.toString(),
      );
      // Deliberately do NOT complete the transaction - StoreKit will redeliver it
      // (e.g. on next app launch) so the user gets a free retry instead of a lost purchase.
      onPurchaseError?.call('Purchase succeeded but verification failed. Please reopen the app to retry.');
    }
  }

  void _handleError(PurchaseDetails details) {
    debugPrint('IAPService: ✗ Purchase ERROR');
    debugPrint('IAPService: ${details.error?.message ?? "Unknown error"}');
    IAPLogger.log(
      'purchase_error',
      level: 'error',
      productId: details.productID,
      transactionId: details.purchaseID,
      message: details.error?.message,
      detail: {'code': details.error?.code, 'source': details.error?.source, 'details': details.error?.details?.toString()},
    );
    onPurchaseError?.call(details.error?.message ?? 'Purchase failed');
  }

  void _handleCancelled(PurchaseDetails details) {
    debugPrint('IAPService: ✗ Purchase CANCELLED by user');
    IAPLogger.log('purchase_cancelled', productId: details.productID, transactionId: details.purchaseID);
    onPurchaseCancelled?.call();
  }

  void _handleRestored(PurchaseDetails details) async {
    debugPrint('IAPService: ↻ Purchase RESTORED');
    debugPrint('IAPService: Product: ${details.productID}');
    IAPLogger.log('purchase_restored', productId: details.productID, transactionId: details.purchaseID);

    // CRITICAL: Auto-sync restored purchase to database
    // This handles the case where user has subscription in StoreKit but not in database
    try {
      debugPrint('IAPService: Auto-syncing restored purchase to database...');
      final syncService = SubscriptionSyncService();
      await syncService.syncFromStoreKit(details.productID);
      debugPrint('IAPService: ✓ Restored purchase synced to database');
      IAPLogger.log('restore_sync_success', productId: details.productID, transactionId: details.purchaseID);
    } catch (e) {
      debugPrint('IAPService: ✗ Failed to sync restored purchase: $e');
      IAPLogger.log(
        'restore_sync_failed',
        level: 'error',
        productId: details.productID,
        transactionId: details.purchaseID,
        message: e.toString(),
      );
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
    IAPLogger.log('restore_initiated');

    if (!_isAvailable) {
      IAPLogger.log('restore_store_unavailable', level: 'error');
      onPurchaseError?.call('Store not available');
      return;
    }

    try {
      await _iap.restorePurchases();
      debugPrint('IAPService: Restore initiated');
    } catch (e) {
      debugPrint('IAPService: Restore error: $e');
      IAPLogger.log('restore_call_exception', level: 'error', message: e.toString());
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

  /// Sync database with current StoreKit state.
  ///
  /// Deliberately one-directional: only ever ADDS a subscription found in
  /// StoreKit but missing from the database. It must NOT cancel a database
  /// subscription just because *this* device's local StoreKit transaction
  /// queue doesn't have it - that queue is empty by default on Android/web
  /// (see checkActiveSubscriptions above) and on any fresh iOS install/device
  /// until the user explicitly restores purchases, even for a fully valid,
  /// still-active subscription. Treating that absence as "cancelled" was
  /// wiping out real subscriptions the moment a user opened this screen on a
  /// different device or platform than the one they purchased on. Real
  /// cancellations must be detected server-side (Apple App Store Server
  /// Notifications V2 - not yet implemented, tracked separately) or by
  /// re-validating the receipt, never by local-device absence.
  Future<void> syncDatabaseWithStoreKit() async {
    debugPrint('IAPService: Syncing database with StoreKit state...');

    final storeKitState = await checkActiveSubscriptions();
    final hasStoreKitSub = storeKitState['hasActive'] as bool;
    final storeKitProducts = storeKitState['products'] as List<String>;

    final syncService = SubscriptionSyncService();
    final hasDatabaseSub = await syncService.hasActiveSubscription();

    debugPrint('IAPService: StoreKit has subscription: $hasStoreKitSub');
    debugPrint('IAPService: Database has subscription: $hasDatabaseSub');
    IAPLogger.log(
      'sync_checked',
      detail: {
        'hasStoreKitSub': hasStoreKitSub,
        'hasDatabaseSub': hasDatabaseSub,
        'storeKitProducts': storeKitProducts,
      },
    );

    // StoreKit has subscription but database doesn't (RESTORE NEEDED)
    if (!hasDatabaseSub && hasStoreKitSub && storeKitProducts.isNotEmpty) {
      debugPrint('IAPService: ⚠️  SUBSCRIPTION FOUND IN STOREKIT - Syncing to database...');
      await syncService.syncFromStoreKit(storeKitProducts.first);
      return;
    }

    debugPrint('IAPService: ✓ Database and StoreKit are in sync');
  }

  /// Cancel subscription in database when StoreKit shows it's cancelled.
  /// Currently unused (see syncDatabaseWithStoreKit) - kept for when real
  /// server-verified cancellation detection (ASN v2) is wired up.
  // ignore: unused_element
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
