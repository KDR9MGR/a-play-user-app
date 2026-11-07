import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/subscription/model/subscription_model.dart';
import '../../features/subscription/service/apple_verification_exception.dart';
import '../../features/subscription/service/subscription_service.dart';
import 'iap_logger.dart';

/// Calls `verify-apple-receipt`; swapped out in tests.
typedef AppleReceiptVerifier = Future<UserSubscription> Function({
  required String productId,
  String? transactionId,
  required String receiptData,
  DateTime? transactionDate,
});

/// A purchase that Apple confirmed AND the backend verified and activated.
class IapPurchaseResult {
  final String productId;
  final String transactionId;

  /// The row the backend wrote (real plan, tier, end date).
  final UserSubscription subscription;

  /// Store listing for [productId], if the product list happens to be loaded
  /// (it is not, for transactions StoreKit redelivers at launch).
  final ProductDetails? product;

  const IapPurchaseResult({
    required this.productId,
    required this.transactionId,
    required this.subscription,
    this.product,
  });
}

/// Result of an explicit "Restore Purchases".
class RestoreOutcome {
  /// Distinct transactions the backend verified and activated.
  final int restored;

  /// Transactions that could not be verified.
  final int failed;

  /// User-facing reason for the last failure, if any.
  final String? message;

  /// The restored subscription that runs longest, if any.
  final UserSubscription? subscription;

  const RestoreOutcome({
    this.restored = 0,
    this.failed = 0,
    this.message,
    this.subscription,
  });
}

class _Outcome {
  final UserSubscription? subscription;
  final AppleVerificationException? error;
  const _Outcome.ok(UserSubscription this.subscription) : error = null;
  const _Outcome.failed(AppleVerificationException this.error) : subscription = null;
  bool get ok => subscription != null;
}

/// Tracks one "Restore Purchases" run: restored transactions arrive
/// asynchronously on the purchase stream, so the run has to wait for the
/// stream to go quiet and for every verification it started to finish.
class _RestoreSession {
  DateTime lastEventAt = DateTime.now();
  final List<Future<void>> pending = [];
  final Set<String> verifiedKeys = {};
  int failed = 0;
  String? lastFailure;
  UserSubscription? best;

  void touch() => lastEventAt = DateTime.now();

  void recordSuccess(String key, UserSubscription sub) {
    verifiedKeys.add(key);
    if (best == null || sub.endDate.isAfter(best!.endDate)) best = sub;
  }

  void recordFailure(String message) {
    failed++;
    lastFailure = message;
  }

  Future<void> settle({required Duration quiet, required Duration timeout}) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline) &&
        DateTime.now().difference(lastEventAt) < quiet) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
    final remaining = deadline.difference(DateTime.now());
    if (pending.isNotEmpty && !remaining.isNegative) {
      await Future.wait(pending).timeout(remaining, onTimeout: () => const []);
    }
  }

  RestoreOutcome outcome() => RestoreOutcome(
        restored: verifiedKeys.length,
        failed: failed,
        message: lastFailure,
        subscription: best,
      );
}

/// Apple In-App Purchase for A-Play subscriptions.
///
/// Money-handling rules this class enforces:
///  * A transaction is only FINISHED (`completePurchase`) after the backend
///    verified it with Apple, or after the backend said it can never be
///    verified (expired / refunded / forged). A transient failure leaves it
///    unfinished so StoreKit redelivers it and nothing paid for is lost.
///  * Verification never depends on the product list being loaded: StoreKit
///    redelivers unfinished transactions the moment the stream is listened to,
///    which is before products are queried.
///  * Each transaction is verified once at a time, however many paths (stream
///    redelivery, restore, retry) see it.
///  * A purchase is bound to the buyer's account (`appAccountToken` = user id,
///    signed by Apple into the transaction) so it can't be reused by another
///    account on the same Apple ID or device.
class IAPService {
  static final IAPService instance = IAPService._internal();
  factory IAPService() => instance;

  IAPService._internal()
      : _iap = InAppPurchase.instance,
        _verify = _defaultVerifier,
        _currentUserId = _defaultUserId,
        _retryDelays = const [Duration(seconds: 2), Duration(seconds: 5)],
        _restoreQuiet = const Duration(milliseconds: 1500),
        _restoreTimeout = const Duration(seconds: 25);

  @visibleForTesting
  IAPService.forTesting({
    required InAppPurchase iap,
    required AppleReceiptVerifier verify,
    required String? Function() currentUserId,
    List<Duration> retryDelays = const [],
    Duration restoreQuiet = const Duration(milliseconds: 50),
    Duration restoreTimeout = const Duration(seconds: 5),
  })  : _iap = iap,
        _verify = verify,
        _currentUserId = currentUserId,
        _retryDelays = retryDelays,
        _restoreQuiet = restoreQuiet,
        _restoreTimeout = restoreTimeout;

  static Future<UserSubscription> _defaultVerifier({
    required String productId,
    String? transactionId,
    required String receiptData,
    DateTime? transactionDate,
  }) =>
      SubscriptionService().verifyAndActivateAppleSubscription(
        productId: productId,
        transactionId: transactionId,
        receiptData: receiptData,
        transactionDate: transactionDate,
      );

  static String? _defaultUserId() => Supabase.instance.client.auth.currentUser?.id;

  final InAppPurchase _iap;
  final AppleReceiptVerifier _verify;
  final String? Function() _currentUserId;
  final List<Duration> _retryDelays;
  final Duration _restoreQuiet;
  final Duration _restoreTimeout;

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

  /// Verifications currently running, by transaction id - the dedupe guard.
  final Map<String, Future<_Outcome>> _inFlight = {};

  /// Transactions verified this session, by transaction id.
  final Map<String, UserSubscription> _verified = {};

  /// Transactions whose verification failed transiently. Still unfinished in
  /// StoreKit; retried by [retryPendingVerifications] and redelivered on the
  /// next launch.
  final Map<String, PurchaseDetails> _held = {};

  /// Product the user just tapped "Subscribe" on; lets us tell the result of
  /// their own purchase (show UI) from a background redelivery (stay quiet).
  String? _initiatedProductId;

  _RestoreSession? _restoreSession;
  Future<RestoreOutcome>? _restoreRun;

  final StreamController<UserSubscription> _verifiedController =
      StreamController<UserSubscription>.broadcast();

  // Callbacks (set by the subscription screen while it is on screen)
  void Function(IapPurchaseResult result)? onPurchaseSuccess;
  void Function(String error)? onPurchaseError;
  void Function()? onPurchaseCancelled;

  /// The App Store is waiting on someone else (Ask to Buy / parental
  /// approval, strong customer authentication). Nothing is charged or active
  /// yet; the result arrives later on the stream.
  void Function()? onPurchasePending;

  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;
  List<ProductDetails> get products => _products;

  /// True while a paid transaction is waiting for the backend to confirm it.
  bool get hasPendingVerification => _held.isNotEmpty;

  /// Fires for every subscription the backend verified and activated -
  /// including ones recovered silently at launch - so app-wide providers can
  /// refresh.
  Stream<UserSubscription> get verifiedSubscriptions => _verifiedController.stream;

  /// Start listening for purchases. Must run at app start: StoreKit redelivers
  /// unfinished transactions as soon as the stream has a listener.
  ///
  /// Never throws - a store problem must not stop the app from launching.
  /// Pass [awaitProducts] = false at startup so the (network) product query
  /// doesn't hold up launch; the subscription screen loads products itself.
  Future<void> initialize({bool awaitProducts = true}) async {
    if (_isInitialized) {
      debugPrint('IAPService: Already initialized');
      return;
    }

    debugPrint('IAPService: Initializing...');
    IAPLogger.log('init_start');

    try {
      _isAvailable = await _iap.isAvailable();
    } catch (e) {
      _isAvailable = false;
      IAPLogger.log('init_availability_check_failed', level: 'error', message: e.toString());
    }
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
      try {
        final iosPlatform = _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatform.setDelegate(PaymentQueueDelegate());
      } catch (e) {
        IAPLogger.log('init_delegate_failed', level: 'warn', message: e.toString());
      }
    }

    // Exactly one listener, ever: a second would verify every transaction twice.
    await _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => debugPrint('IAPService: Purchase stream done'),
      onError: (Object error) {
        debugPrint('IAPService: Purchase stream error: $error');
        onPurchaseError?.call(error.toString());
      },
    );

    // Initialized as soon as we can receive purchases. A failing product
    // query must not leave the service half-set-up (it used to, which let a
    // retry attach a second listener).
    _isInitialized = true;

    // NOTE: restorePurchases() is deliberately NOT called here. Doing so on
    // every launch can trigger the App Store sign-in prompt at startup
    // (Guideline 5.1.1) and floods the stream. Restore runs only when the
    // user taps "Restore Purchases".
    if (awaitProducts) {
      await _loadProductsSafely();
    } else {
      unawaited(_loadProductsSafely());
    }
    debugPrint('IAPService: Initialization complete');
  }

  /// Re-queries the store for products without re-running initialize() (a
  /// one-shot). What the subscription screen's "Retry" should call.
  Future<void> reloadProducts() async {
    if (!_isAvailable) {
      debugPrint('IAPService: Cannot reload products, store not available');
      return;
    }
    await _loadProductsSafely();
  }

  Future<void> _loadProductsSafely() async {
    try {
      await _loadProducts();
    } catch (e) {
      debugPrint('IAPService: Product query threw: $e');
      IAPLogger.log('products_query_exception', level: 'error', message: e.toString());
    }
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
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAPService: Products not found: ${response.notFoundIDs}');
    }

    // notFoundIDs is the #1 real-world cause of "purchase doesn't work" in
    // production: these product IDs aren't in "Ready to Submit"/"Approved"
    // state in App Store Connect (or the Paid Apps Agreement isn't active), so
    // StoreKit won't return them and the buy button never reaches Apple.
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
      const error = 'Store not available. Please try on a physical device.';
      IAPLogger.log('purchase_store_unavailable', level: 'error', productId: productId, message: error);
      onPurchaseError?.call(error);
      return;
    }

    // The purchase is bound to the signed-in account (see class docs). No
    // account, no purchase - otherwise there'd be nobody to activate it for.
    final userId = _currentUserId();
    if (userId == null) {
      const error = 'Please sign in to subscribe.';
      IAPLogger.log('purchase_not_signed_in', level: 'warn', productId: productId);
      onPurchaseError?.call(error);
      return;
    }

    final product = _products.where((p) => p.id == productId).firstOrNull;
    if (product == null) {
      final error = 'Product not found: $productId';
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

    // applicationUserName becomes the StoreKit 2 appAccountToken (must be a
    // UUID - Supabase user ids are) and is signed into the transaction.
    final purchaseParam = PurchaseParam(
      productDetails: product,
      applicationUserName: userId,
    );

    _initiatedProductId = productId;
    try {
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      if (success) {
        IAPLogger.log('purchase_buy_call_succeeded', productId: productId);
      } else {
        _initiatedProductId = null;
        IAPLogger.log('purchase_buy_call_failed', level: 'error', productId: productId);
        onPurchaseError?.call('Failed to start purchase');
      }
    } catch (e) {
      _initiatedProductId = null;
      IAPLogger.log('purchase_buy_call_exception', level: 'error', productId: productId, message: e.toString());
      onPurchaseError?.call(e.toString());
    }
  }

  /// Handle purchase updates from the store
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    debugPrint('IAPService: Purchase update: ${purchaseDetailsList.length} item(s)');
    _restoreSession?.touch();

    for (final details in purchaseDetailsList) {
      debugPrint('IAPService: ${details.productID} -> ${details.status}');

      switch (details.status) {
        case PurchaseStatus.pending:
          _handlePending(details);
          break;

        case PurchaseStatus.purchased:
          unawaited(_processTransaction(details, restored: false));
          break;

        case PurchaseStatus.restored:
          unawaited(_processTransaction(details, restored: true));
          break;

        case PurchaseStatus.error:
          _handleError(details);
          unawaited(_finish(details));
          break;

        case PurchaseStatus.canceled:
          _handleCancelled(details);
          unawaited(_finish(details));
          break;
      }
      // Purchased / restored transactions are finished by _processTransaction,
      // and only once the backend has dealt with them.
    }
  }

  void _handlePending(PurchaseDetails details) {
    IAPLogger.log(
      'purchase_pending',
      level: 'warn',
      productId: details.productID,
      transactionId: details.purchaseID,
    );
    // Not charged and not active yet - the final result arrives later on this
    // stream. Let the UI stop its spinner instead of hanging forever.
    onPurchasePending?.call();
  }

  /// Verify one StoreKit transaction with the backend and finish it
  /// accordingly. Used for fresh purchases, restores and redelivered
  /// transactions alike.
  Future<void> _processTransaction(
    PurchaseDetails details, {
    required bool restored,
    bool surfaceErrors = false,
  }) async {
    final session = restored ? _restoreSession : null;
    final userInitiated =
        surfaceErrors || (!restored && _initiatedProductId == details.productID);

    final key = details.purchaseID;
    final receiptData = details.verificationData.serverVerificationData;

    if (key == null || receiptData.isEmpty) {
      IAPLogger.log(
        'verify_call_skipped_missing_data',
        level: 'error',
        productId: details.productID,
        transactionId: key,
        detail: {'hasTransactionId': key != null, 'receiptDataLength': receiptData.length},
      );
      const message = 'This purchase is missing data from the App Store. '
          'Please try again on a real device.';
      session?.recordFailure(message);
      if (userInitiated && session == null) {
        _initiatedProductId = null;
        onPurchaseError?.call(message);
      }
      return;
    }

    final alreadyVerified = _verified[key];
    final _Outcome outcome;
    if (alreadyVerified != null) {
      outcome = _Outcome.ok(alreadyVerified);
    } else {
      final run = _inFlight.putIfAbsent(key, () => _verifyWithRetry(details, key, receiptData));
      if (session != null) session.pending.add(run.then((_) {}));
      outcome = await run;
      _inFlight.remove(key);
    }

    if (outcome.ok) {
      final sub = outcome.subscription!;
      final firstTime = _verified[key] == null;
      _verified[key] = sub;
      _held.remove(key);
      await _finish(details);
      if (firstTime) _verifiedController.add(sub);

      if (session != null) {
        session.recordSuccess(key, sub);
        return;
      }
      // The same transaction can reach us twice (e.g. stream redelivery while
      // a restore ran). The UI was told the first time; don't tell it again.
      if (!firstTime) return;
      if (_initiatedProductId == details.productID) _initiatedProductId = null;
      final product = _products.where((p) => p.id == details.productID).firstOrNull;
      onPurchaseSuccess?.call(IapPurchaseResult(
        productId: details.productID,
        transactionId: key,
        subscription: sub,
        product: product,
      ));
      return;
    }

    final error = outcome.error!;
    if (error.isOwnedByOtherAccount) {
      // The purchase is real but belongs to another A-Play account. Do NOT
      // finish it: that account still needs StoreKit to redeliver it.
      IAPLogger.log('verify_owned_by_other_account', level: 'warn',
          productId: details.productID, transactionId: key);
    } else if (error.isPermanent) {
      // Retrying can never work (expired / refunded / forged). Finish it so
      // StoreKit stops redelivering it at every launch.
      await _finish(details);
    } else {
      // Transient: keep it unfinished so it is redelivered and retried.
      _held[key] = details;
    }

    if (session != null) {
      session.recordFailure(error.userMessage);
    } else if (userInitiated) {
      if (_initiatedProductId == details.productID) _initiatedProductId = null;
      onPurchaseError?.call(error.userMessage);
    }
    // Background redelivery that fails: logged by _verifyWithRetry, no UI.
  }

  Future<_Outcome> _verifyWithRetry(
    PurchaseDetails details,
    String transactionId,
    String receiptData,
  ) async {
    IAPLogger.log('verify_call_start', productId: details.productID, transactionId: transactionId);

    // transactionDate is milliseconds since the epoch, as a string.
    final ms = int.tryParse(details.transactionDate ?? '');
    final transactionDate =
        ms != null ? DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true) : null;

    for (var attempt = 0;; attempt++) {
      try {
        final sub = await _verify(
          productId: details.productID,
          transactionId: transactionId,
          receiptData: receiptData,
          transactionDate: transactionDate,
        );
        IAPLogger.log('verify_call_success', productId: details.productID, transactionId: transactionId);
        return _Outcome.ok(sub);
      } catch (e) {
        final error = e is AppleVerificationException
            ? e
            : AppleVerificationException(e.toString());
        IAPLogger.log(
          'verify_call_failed',
          level: 'error',
          productId: details.productID,
          transactionId: transactionId,
          message: error.message,
          detail: {'code': error.code, 'status': error.status, 'attempt': attempt},
        );
        if (error.isPermanent || attempt >= _retryDelays.length) {
          return _Outcome.failed(error);
        }
        await Future<void>.delayed(_retryDelays[attempt]);
      }
    }
  }

  Future<void> _finish(PurchaseDetails details) async {
    if (!details.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(details);
    } catch (e) {
      IAPLogger.log('complete_purchase_failed', level: 'error',
          productId: details.productID, transactionId: details.purchaseID, message: e.toString());
    }
  }

  void _handleError(PurchaseDetails details) {
    IAPLogger.log(
      'purchase_error',
      level: 'error',
      productId: details.productID,
      transactionId: details.purchaseID,
      message: details.error?.message,
      detail: {'code': details.error?.code, 'source': details.error?.source, 'details': details.error?.details?.toString()},
    );
    _initiatedProductId = null;
    onPurchaseError?.call(details.error?.message ?? 'Purchase failed');
  }

  void _handleCancelled(PurchaseDetails details) {
    IAPLogger.log('purchase_cancelled', productId: details.productID, transactionId: details.purchaseID);
    _initiatedProductId = null;
    onPurchaseCancelled?.call();
  }

  /// Restore previous purchases (the user tapped "Restore Purchases").
  ///
  /// Each restored transaction is verified with the backend using ITS OWN
  /// signed data - exactly like a fresh purchase. (This used to ignore that
  /// data, pull the legacy app receipt instead - often empty under StoreKit 2
  /// - and report success whether or not anything was activated.) Completes
  /// once the stream has gone quiet and every verification it started is done.
  Future<RestoreOutcome> restorePurchases() {
    final running = _restoreRun;
    if (running != null) return running;
    return _restoreRun = _runRestore().whenComplete(() => _restoreRun = null);
  }

  Future<RestoreOutcome> _runRestore() async {
    debugPrint('IAPService: Restoring purchases...');
    IAPLogger.log('restore_initiated');

    if (!_isAvailable) {
      IAPLogger.log('restore_store_unavailable', level: 'error');
      return const RestoreOutcome(message: 'The App Store is not available right now.');
    }

    final session = _restoreSession = _RestoreSession();
    try {
      await _iap.restorePurchases();
      await session.settle(quiet: _restoreQuiet, timeout: _restoreTimeout);
    } catch (e) {
      IAPLogger.log('restore_call_exception', level: 'error', message: e.toString());
      session.recordFailure('Failed to restore purchases. Please try again.');
    } finally {
      _restoreSession = null;
    }

    final outcome = session.outcome();
    IAPLogger.log('restore_finished', detail: {'restored': outcome.restored, 'failed': outcome.failed});
    return outcome;
  }

  /// Retry transactions that were paid for but could not be confirmed with the
  /// backend (e.g. no network at the time). Returns how many succeeded.
  /// Also what the old "sync with StoreKit" does now: that queried the legacy
  /// StoreKit 1 payment queue, which is always empty under StoreKit 2.
  Future<int> retryPendingVerifications() async {
    var succeeded = 0;
    for (final details in List<PurchaseDetails>.of(_held.values)) {
      final key = details.purchaseID;
      if (key == null || _inFlight.containsKey(key)) continue;
      _held.remove(key);
      await _processTransaction(details, restored: false, surfaceErrors: true);
      if (_verified.containsKey(key)) succeeded++;
    }
    return succeeded;
  }

  /// Kept for existing call sites; see [retryPendingVerifications].
  Future<int> syncDatabaseWithStoreKit() => retryPendingVerifications();

  /// Get product details by ID
  ProductDetails? getProduct(String productId) {
    return _products.where((p) => p.id == productId).firstOrNull;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _subscription = null;

    if (!kIsWeb && Platform.isIOS) {
      try {
        _iap
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>()
            .setDelegate(null);
      } catch (_) {}
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
