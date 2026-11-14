import 'dart:async';

import 'package:a_play/core/services/iap_service.dart';
import 'package:a_play/features/subscription/model/subscription_model.dart';
import 'package:a_play/features/subscription/service/apple_verification_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// StoreKit stand-in: records what the service asks of it and lets a test push
/// purchase events onto the stream.
class FakeIap extends Fake implements InAppPurchase {
  int listenCount = 0;
  late final StreamController<List<PurchaseDetails>> controller =
      StreamController<List<PurchaseDetails>>.broadcast(onListen: () => listenCount++);

  bool available = true;
  Object? availabilityError;
  Object? queryError;
  List<ProductDetails> products = [];
  final List<PurchaseDetails> completed = [];
  PurchaseParam? lastBuyParam;
  int buyCalls = 0;
  void Function()? onRestore;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => controller.stream;

  @override
  Future<bool> isAvailable() async {
    if (availabilityError != null) throw availabilityError!;
    return available;
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async {
    if (queryError != null) throw queryError!;
    return ProductDetailsResponse(productDetails: products, notFoundIDs: const []);
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyCalls++;
    lastBuyParam = purchaseParam;
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async => completed.add(purchase);

  @override
  Future<void> restorePurchases({String? applicationUserName}) async => onRestore?.call();

  void emit(List<PurchaseDetails> events) => controller.add(events);
}

PurchaseDetails tx({
  String? id = 'tx1',
  String product = '1month',
  PurchaseStatus status = PurchaseStatus.purchased,
  String jws = 'header.payload.signature',
  bool pendingComplete = true,
}) {
  final details = PurchaseDetails(
    purchaseID: id,
    productID: product,
    verificationData: PurchaseVerificationData(
      localVerificationData: jws,
      serverVerificationData: jws,
      source: 'app_store',
    ),
    transactionDate: '1900000000000',
    status: status,
  );
  details.pendingCompletePurchase = pendingComplete;
  return details;
}

ProductDetails product(String id) => ProductDetails(
      id: id,
      title: 'Monthly (A-Play)',
      description: 'd',
      price: 'GHS 50',
      rawPrice: 50,
      currencyCode: 'GHS',
    );

UserSubscription subscription({String id = 's1', DateTime? end}) =>
    UserSubscription.fromJson({
      'id': id,
      'user_id': 'user-1',
      'status': 'active',
      'start_date': DateTime(2030, 1, 1).toIso8601String(),
      'end_date': (end ?? DateTime(2030, 2, 1)).toIso8601String(),
    });

class Verifier {
  final List<Map<String, Object?>> calls = [];
  final List<Object> script; // each entry: UserSubscription to return, or an exception to throw
  Verifier(this.script);

  Future<UserSubscription> call({
    required String productId,
    String? transactionId,
    required String receiptData,
    DateTime? transactionDate,
  }) async {
    calls.add({'productId': productId, 'transactionId': transactionId, 'receiptData': receiptData});
    final next = script.length > 1 ? script.removeAt(0) : script.first;
    if (next is UserSubscription) return next;
    throw next;
  }
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 30));

void main() {
  late FakeIap iap;
  String? userId;

  IAPService build(Verifier verifier, {List<Duration> retryDelays = const []}) {
    return IAPService.forTesting(
      iap: iap,
      verify: verifier.call,
      currentUserId: () => userId,
      retryDelays: retryDelays,
    );
  }

  setUp(() {
    iap = FakeIap();
    userId = '8f1c6a4e-1111-4222-8333-444455556666';
  });

  group('launch redelivery', () {
    test('a purchase redelivered before products load is still verified and finished', () async {
      final verifier = Verifier([subscription()]);
      final service = build(verifier);
      final verified = <UserSubscription>[];
      service.verifiedSubscriptions.listen(verified.add);

      // Exactly what happens at app start: the stream gets a listener and
      // StoreKit immediately redelivers an unfinished transaction - while the
      // product list is still empty.
      await service.initialize(awaitProducts: false);
      expect(service.products, isEmpty);
      iap.emit([tx()]);
      await settle();

      expect(verifier.calls, hasLength(1));
      expect(verifier.calls.single['productId'], '1month');
      expect(verifier.calls.single['transactionId'], 'tx1');
      expect(verifier.calls.single['receiptData'], 'header.payload.signature');
      expect(iap.completed.map((d) => d.purchaseID), ['tx1']);
      expect(verified, hasLength(1)); // lets app-wide providers refresh
    });

    test('a background redelivery that fails does not pop an error at the user', () async {
      final verifier = Verifier([const AppleVerificationException('offline')]);
      final service = build(verifier);
      var errors = 0;
      service.onPurchaseError = (_) => errors++;

      await service.initialize(awaitProducts: false);
      iap.emit([tx()]);
      await settle();

      expect(errors, 0);
      expect(iap.completed, isEmpty); // stays unfinished -> redelivered next launch
      expect(service.hasPendingVerification, isTrue);
    });
  });

  group('purchase', () {
    test('is bound to the signed-in account via applicationUserName', () async {
      iap.products = [product('1month')];
      final service = build(Verifier([subscription()]));
      await service.initialize();

      await service.purchaseSubscription('1month');

      expect(iap.buyCalls, 1);
      expect(iap.lastBuyParam!.applicationUserName, userId);
    });

    test('is refused when nobody is signed in', () async {
      iap.products = [product('1month')];
      userId = null;
      final service = build(Verifier([subscription()]));
      await service.initialize();
      String? error;
      service.onPurchaseError = (e) => error = e;

      await service.purchaseSubscription('1month');

      expect(iap.buyCalls, 0);
      expect(error, contains('sign in'));
    });

    test('success reports the REAL subscription (plan end date, transaction id)', () async {
      iap.products = [product('1month')];
      final end = DateTime(2031, 5, 17);
      final service = build(Verifier([subscription(end: end)]));
      await service.initialize();
      IapPurchaseResult? result;
      service.onPurchaseSuccess = (r) => result = r;

      await service.purchaseSubscription('1month');
      iap.emit([tx()]);
      await settle();

      expect(result!.transactionId, 'tx1');
      expect(result!.subscription.endDate, end);
      expect(result!.product?.id, '1month');
    });

    test('pending (Ask to Buy) tells the UI to stop spinning and verifies nothing', () async {
      final verifier = Verifier([subscription()]);
      final service = build(verifier);
      await service.initialize();
      var pending = 0;
      service.onPurchasePending = () => pending++;

      iap.emit([tx(status: PurchaseStatus.pending, pendingComplete: false)]);
      await settle();

      expect(pending, 1);
      expect(verifier.calls, isEmpty);
    });

    test('cancel and store errors reach the UI', () async {
      final service = build(Verifier([subscription()]));
      await service.initialize();
      var cancelled = 0;
      String? error;
      service.onPurchaseCancelled = () => cancelled++;
      service.onPurchaseError = (e) => error = e;

      iap.emit([tx(id: 'c1', status: PurchaseStatus.canceled, pendingComplete: false)]);
      iap.emit([
        tx(id: 'e1', status: PurchaseStatus.error, pendingComplete: false)
          ..error = IAPError(source: 'app_store', code: 'x', message: 'Card declined'),
      ]);
      await settle();

      expect(cancelled, 1);
      expect(error, 'Card declined');
    });
  });

  group('verification failures', () {
    test('transient failure: kept unfinished, explained, and recoverable with a retry', () async {
      iap.products = [product('1month')];
      final verifier = Verifier([const AppleVerificationException('timeout'), subscription()]);
      final service = build(verifier);
      await service.initialize();
      String? error;
      IapPurchaseResult? result;
      service.onPurchaseError = (e) => error = e;
      service.onPurchaseSuccess = (r) => result = r;

      await service.purchaseSubscription('1month');
      iap.emit([tx()]);
      await settle();

      expect(error, contains('went through with Apple'));
      expect(error, contains('won\'t be charged again'));
      expect(iap.completed, isEmpty);
      expect(service.hasPendingVerification, isTrue);

      final recovered = await service.retryPendingVerifications();

      expect(recovered, 1);
      expect(iap.completed.map((d) => d.purchaseID), ['tx1']);
      expect(result?.transactionId, 'tx1');
      expect(service.hasPendingVerification, isFalse);
    });

    test('transient failures are retried automatically before giving up', () async {
      final verifier = Verifier([
        const AppleVerificationException('a'),
        const AppleVerificationException('b'),
        subscription(),
      ]);
      final service = build(verifier, retryDelays: const [Duration.zero, Duration.zero]);
      await service.initialize();

      iap.emit([tx()]);
      await settle();

      expect(verifier.calls, hasLength(3));
      expect(iap.completed, hasLength(1));
    });

    test('permanent failure (expired): finished so it is not redelivered forever, no retries', () async {
      final verifier = Verifier([const AppleVerificationException('expired', code: 'expired')]);
      final service = build(verifier, retryDelays: const [Duration.zero, Duration.zero]);
      await service.initialize();
      var errors = 0;
      service.onPurchaseError = (_) => errors++;

      iap.emit([tx()]);
      await settle();

      expect(verifier.calls, hasLength(1)); // not retried
      expect(iap.completed, hasLength(1)); // finished
      expect(service.hasPendingVerification, isFalse);
      expect(errors, 0); // it was a background redelivery
    });

    test('a purchase owned by another account is NOT finished (its owner still needs it)', () async {
      final verifier = Verifier([
        const AppleVerificationException('other', code: 'owned_by_other_account'),
      ]);
      final service = build(verifier);
      await service.initialize();

      iap.emit([tx()]);
      await settle();

      expect(iap.completed, isEmpty);
      expect(service.hasPendingVerification, isFalse); // and not retried for this account
    });

    test('the same transaction delivered twice is verified once and reported once', () async {
      final gate = Completer<UserSubscription>();
      var verifyCalls = 0;
      final service = IAPService.forTesting(
        iap: iap,
        verify: ({required productId, transactionId, required receiptData, transactionDate}) {
          verifyCalls++;
          return gate.future;
        },
        currentUserId: () => userId,
      );
      await service.initialize();
      var successes = 0;
      service.onPurchaseSuccess = (_) => successes++;

      iap.emit([tx()]);
      iap.emit([tx()]); // redelivered while the first verification is in flight
      await settle();
      gate.complete(subscription());
      await settle();

      expect(verifyCalls, 1);
      expect(successes, 1);
    });
  });

  group('restore', () {
    test('verifies each restored transaction with its OWN signed data and reports the outcome', () async {
      final verifier = Verifier([
        subscription(id: 'short', end: DateTime(2030, 2, 1)),
        subscription(id: 'long', end: DateTime(2030, 9, 1)),
      ]);
      final service = build(verifier);
      await service.initialize();
      var successCallbacks = 0;
      service.onPurchaseSuccess = (_) => successCallbacks++;
      iap.onRestore = () {
        scheduleMicrotask(() => iap.emit([
              tx(id: 'tx-a', product: '7day', status: PurchaseStatus.restored, jws: 'a.a.a'),
              tx(id: 'tx-b', product: '1month', status: PurchaseStatus.restored, jws: 'b.b.b'),
            ]));
      };

      final outcome = await service.restorePurchases();

      expect(outcome.restored, 2);
      expect(outcome.failed, 0);
      expect(outcome.subscription!.id, 'long'); // the one that runs longest
      expect(verifier.calls.map((c) => c['receiptData']), containsAll(['a.a.a', 'b.b.b']));
      expect(verifier.calls.map((c) => c['transactionId']), containsAll(['tx-a', 'tx-b']));
      expect(successCallbacks, 0); // one aggregate result, not a success screen per transaction
    });

    test('a restore whose verification fails is reported as a failure, not a success', () async {
      final verifier = Verifier([
        const AppleVerificationException('bad', code: 'invalid_receipt'),
      ]);
      final service = build(verifier);
      await service.initialize();
      iap.onRestore = () {
        scheduleMicrotask(() =>
            iap.emit([tx(id: 'tx-a', status: PurchaseStatus.restored)]));
      };

      final outcome = await service.restorePurchases();

      expect(outcome.restored, 0);
      expect(outcome.failed, 1);
      expect(outcome.message, contains('validate'));
    });

    test('nothing to restore is an empty outcome, not an error', () async {
      final service = build(Verifier([subscription()]));
      await service.initialize();

      final outcome = await service.restorePurchases();

      expect(outcome.restored, 0);
      expect(outcome.failed, 0);
    });
  });

  group('initialize', () {
    test('never throws when the store query fails, and never stacks listeners', () async {
      iap.queryError = Exception('StoreKit: Failed to get response from platform');
      final service = build(Verifier([subscription()]));

      await service.initialize(); // must not throw
      await service.initialize(); // second call is a no-op

      expect(service.isInitialized, isTrue);
      expect(iap.listenCount, 1);
    });

    test('never throws when the store is unreachable', () async {
      iap.availabilityError = Exception('boom');
      final service = build(Verifier([subscription()]));

      await service.initialize();

      expect(service.isInitialized, isTrue);
      expect(service.isAvailable, isFalse);
    });
  });
}
