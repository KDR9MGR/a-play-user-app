import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:a_play/core/config/paystack_config.dart';

class UnifiedPaymentService {
  static UnifiedPaymentService? _instance;
  final String _publicKey = PaystackConfig.publicKey;
  final String _secretKey = PaystackConfig.secretKey;

  UnifiedPaymentService._() {
    if (_publicKey.isEmpty || _secretKey.isEmpty) {
      throw Exception('Paystack keys not properly configured');
    }
  }

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
      
      if (_secretKey.isEmpty) {
        throw Exception('Paystack secret key not configured');
      }

      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'amount': (amount * 100).round(), // Convert to pesewas
          'reference': reference,
          'callback_url': 'https://standard.paystack.co/close',
          'currency': 'GHS',
          'channels': ['card', 'bank', 'ussd', 'qr', 'mobile_money', 'bank_transfer'],
          'metadata': metadata,
        }),
      );

      debugPrint('Paystack Response: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to initialize transaction: ${errorBody['message'] ?? response.body}');
      }

      final responseData = jsonDecode(response.body);
      if (responseData['status'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to initialize transaction');
      }

      return responseData['data'];
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
            secretKey: _secretKey,
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
  final String secretKey;
  final Function() onSuccess;
  final Function(String) onError;

  const PaystackWebView({
    super.key,
    required this.authorizationUrl,
    required this.reference,
    required this.secretKey,
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
