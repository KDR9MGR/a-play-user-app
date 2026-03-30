import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UnifiedPaymentService {
  static UnifiedPaymentService? _instance;

  UnifiedPaymentService._();

  static UnifiedPaymentService get instance {
    _instance ??= UnifiedPaymentService._();
    return _instance!;
  }

  Future<Map<String, dynamic>> initializeTransaction({
    required String email,
    required double amount,
    required String reference,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      debugPrint('Initializing transaction for amount: ${amount.toString()}');
      debugPrint('Using email: $email');
      debugPrint('Reference: $reference');

      final response = await Supabase.instance.client.functions.invoke(
        'paystack',
        body: {
          'action': 'initialize',
          'email': email,
          'amount': (amount * 100).round(),
          'reference': reference,
          'callback_url': 'https://standard.paystack.co/close',
          'currency': 'GHS',
          'channels': ['card', 'bank', 'ussd', 'qr', 'mobile_money', 'bank_transfer'],
          'metadata': metadata,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to initialize transaction: ${response.status}');
      }

      final responseData = (response.data as Map).cast<String, dynamic>();
      if (responseData['status'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to initialize transaction');
      }

      return (responseData['data'] as Map).cast<String, dynamic>();
    } catch (e) {
      debugPrint('Payment initialization error: $e');
      throw Exception('Payment initialization failed: $e');
    }
  }

  Future<bool> processPayment({
    required BuildContext context,
    required String email,
    required double amount,
    required String reference,
    required Map<String, dynamic> metadata,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      debugPrint('Starting payment process...');
      
      final transactionData = await initializeTransaction(
        email: email,
        amount: amount,
        reference: reference,
        metadata: metadata,
      );

      debugPrint('Transaction initialized: $transactionData');

      if (!context.mounted) return false;

      // Show payment WebView
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: PaystackWebView(
            authorizationUrl: transactionData['authorization_url'],
            reference: reference,
            onSuccess: onSuccess,
            onError: onError,
          ),
        ),
      );

      return result ?? false;
    } catch (e) {
      debugPrint('Payment process error: $e');
      onError(e.toString());
      return false;
    }
  }
}

class PaystackWebView extends StatelessWidget {
  final String authorizationUrl;
  final String reference;
  final Function() onSuccess;
  final Function(String) onError;

  const PaystackWebView({
    super.key,
    required this.authorizationUrl,
    required this.reference,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            onError('Payment cancelled');
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            onError('Payment webview unavailable');
            Navigator.of(context).pop(false);
          },
          child: const Text('Close'),
        ),
      ),
    );
  }
}
