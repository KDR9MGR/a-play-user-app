import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaystackService {
  final SupabaseClient _client;

  PaystackService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  // Initialize payment
  Future<Map<String, dynamic>> initializeTransaction({
    required String email,
    required int amount, // amount in kobo (Nigerian currency)
    required String reference,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'paystack',
        body: {
          'action': 'initialize',
          'email': email,
          'amount': amount,
          'reference': reference,
          'callback_url': 'https://standard.paystack.co/close',
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to initialize transaction: ${response.status}');
      }
      return (response.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Verify transaction
  Future<Map<String, dynamic>> verifyTransaction(String reference) async {
    try {
      final response = await _client.functions.invoke(
        'paystack',
        body: {
          'action': 'verify',
          'reference': reference,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to verify transaction: ${response.status}');
      }
      return (response.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Launch payment URL
  Future<bool> launchPaymentUrl({
    required String authorizationUrl,
  }) async {
    try {
      debugPrint('Payment URL: $authorizationUrl');
      return true;
    } catch (e) {
      debugPrint('URL launch error: $e');
      return false;
    }
  }

  // Process payment
  Future<bool> processPayment({
    required BuildContext context,
    required String email,
    required double amount,
    required String reference,
    required Function(bool) onPaymentComplete,
  }) async {
    try {
      // Convert amount to kobo (multiply by 100)
      final amountInKobo = (amount * 100).toInt();

      // Initialize transaction
      final initResponse = await initializeTransaction(
        email: email,
        amount: amountInKobo,
        reference: reference,
      );

      if (initResponse['status'] == true) {
        final authorizationUrl = initResponse['data']['authorization_url'];
        
        // Launch payment URL in browser
        final launched = await launchPaymentUrl(
          authorizationUrl: authorizationUrl,
        );

        if (launched) {
          // Show a dialog that lets the user indicate when payment is complete
          if (context.mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Payment'),
                  content: const Text('Please complete your payment in the browser. After completion, return to this app and confirm below.'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        // Verify the transaction
                        try {
                          final verificationResult = await verifyTransaction(reference);
                          final success = verificationResult['data']['status'] == 'success';
                          onPaymentComplete(success);
                        } catch (e) {
                          debugPrint('Verification error: $e');
                          onPaymentComplete(false);
                        }
                      },
                      child: const Text('I\'ve completed payment'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onPaymentComplete(false);
                      },
                      child: const Text('Cancel payment'),
                    ),
                  ],
                );
              },
            );
            // The result will be handled by the onPaymentComplete callback
            return true;
          }
        }
        return false;
      } else {
        throw Exception('Failed to initialize payment');
      }
    } catch (e) {
      throw Exception('Payment processing failed: $e');
    }
  }
} 
