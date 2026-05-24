import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

part 'subscription_state.freezed.dart';

/// State for subscription screen and purchase flow
@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState.initial() = _Initial;

  const factory SubscriptionState.loading() = _Loading;

  const factory SubscriptionState.loaded({
    required List<ProductDetails> products,
    @Default(false) bool isPurchasing,
    @Default(false) bool purchaseSuccess,
    String? purchaseError,
  }) = _Loaded;

  const factory SubscriptionState.error(String message) = _Error;
}

/// Extension for easy state checking
extension SubscriptionStateX on SubscriptionState {
  bool get isLoading => this is _Loading;
  bool get isLoaded => this is _Loaded;
  bool get hasError => this is _Error;

  List<ProductDetails> get products {
    return maybeWhen(
      loaded: (products, _, __, ___) => products,
      orElse: () => [],
    );
  }

  bool get isPurchasing {
    return maybeWhen(
      loaded: (_, isPurchasing, __, ___) => isPurchasing,
      orElse: () => false,
    );
  }

  bool get purchaseSuccess {
    return maybeWhen(
      loaded: (_, __, purchaseSuccess, ___) => purchaseSuccess,
      orElse: () => false,
    );
  }

  String? get purchaseError {
    return maybeWhen(
      loaded: (_, __, ___, error) => error,
      error: (message) => message,
      orElse: () => null,
    );
  }

  SubscriptionState copyWith({
    List<ProductDetails>? products,
    bool? isPurchasing,
    bool? purchaseSuccess,
    String? purchaseError,
  }) {
    return maybeWhen(
      loaded: (currentProducts, currentPurchasing, currentSuccess, currentError) {
        return SubscriptionState.loaded(
          products: products ?? currentProducts,
          isPurchasing: isPurchasing ?? currentPurchasing,
          purchaseSuccess: purchaseSuccess ?? currentSuccess,
          purchaseError: purchaseError,
        );
      },
      orElse: () => this,
    );
  }
}
