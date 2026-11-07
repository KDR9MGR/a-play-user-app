/// Why `verify-apple-receipt` did not activate a subscription.
///
/// The distinction that matters to the purchase flow is permanent vs
/// transient. A permanent failure can never succeed on retry (the transaction
/// is expired, refunded, forged, or belongs to another account), so the app
/// should stop retrying; a transient one (network, server error, Apple being
/// unavailable) must leave the StoreKit transaction unfinished so it is
/// redelivered and retried instead of the purchase being lost.
class AppleVerificationException implements Exception {
  /// Server `code` (see `FailureCode` in verify-apple-receipt/index.ts), or
  /// null when the failure carried none - which is treated as transient.
  final String? code;
  final String message;
  final int? status;

  const AppleVerificationException(this.message, {this.code, this.status});

  static const _permanentCodes = {
    'invalid_receipt',
    'expired',
    'revoked',
    'owned_by_other_account',
  };

  /// Retrying can never succeed.
  bool get isPermanent => _permanentCodes.contains(code);

  /// The purchase is fine, but it belongs to a different A-Play account than
  /// the one signed in. Its StoreKit transaction must NOT be finished: the
  /// rightful account still needs it redelivered.
  bool get isOwnedByOtherAccount => code == 'owned_by_other_account';

  /// Plain-language text for the user.
  String get userMessage {
    switch (code) {
      case 'expired':
        return 'This subscription has already expired.';
      case 'revoked':
        return 'This purchase was refunded or revoked by Apple.';
      case 'owned_by_other_account':
        return 'This App Store subscription is linked to a different A-Play '
            'account. Sign in to that account, or contact support.';
      case 'invalid_receipt':
        return 'We couldn\'t validate this purchase with Apple.';
      default:
        return 'Your purchase went through with Apple, but we couldn\'t '
            'activate it yet. You won\'t be charged again - tap Retry or '
            'reopen the app and we\'ll finish activating it.';
    }
  }

  @override
  String toString() =>
      'AppleVerificationException(code: $code, status: $status, message: $message)';
}
