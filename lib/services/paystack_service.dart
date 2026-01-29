import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaystackService {
  static String get _secretKey => dotenv.env['PAYSTACK_SECRET_KEY'] ?? '';

  // Initialize payment
  Future<Map<String, dynamic>> initializeTransaction({
    required String email,
    required int amount, // amount in kobo (Nigerian currency)
    required String reference,
  }) async {
    final url = Uri.parse('https://api.paystack.co/transaction/initialize');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'amount': amount,
          'reference': reference,
          'callback_url': 'https://standard.paystack.co/close',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to initialize transaction: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Verify transaction
  Future<Map<String, dynamic>> verifyTransaction(String reference) async {
    final url = Uri.parse('https://api.paystack.co/transaction/verify/$reference');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify transaction: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Launch payment URL in external browser
  Future<bool> launchPaymentUrl({
    required String authorizationUrl,
  }) async {
    final Uri url = Uri.parse(authorizationUrl);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      } else {
        throw Exception('Could not launch $url');
      }
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
