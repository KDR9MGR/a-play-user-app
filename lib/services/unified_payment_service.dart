import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

class PaystackWebView extends StatefulWidget {
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
  State<PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {
  late final WebViewController _controller;
  bool _isVerifying = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            if (mounted) {
              setState(() => _isLoading = false);
            }

            // Check for payment completion callbacks
            if (url.contains('checkout.paystack.com/close') ||
                url.contains('standard.paystack.co/close') ||
                url == 'aplay://payment-callback') {
              _verifyTransaction();
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  Future<void> _verifyTransaction() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    try {
      debugPrint('Verifying transaction: ${widget.reference}');

      final response = await Supabase.instance.client.functions.invoke(
        'paystack',
        body: {
          'action': 'verify',
          'reference': widget.reference,
        },
      );

      final responseData = (response.data as Map).cast<String, dynamic>();
      final data = (responseData['data'] as Map?)?.cast<String, dynamic>();

      debugPrint('Verification response: $responseData');

      if (response.status == 200 &&
          responseData['status'] == true &&
          data?['status'] == 'success') {
        widget.onSuccess();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Payment verification failed: ${responseData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Verification error: $e');
      widget.onError('Payment verification failed: $e');
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isVerifying,
      onPopInvoked: (didPop) {
        if (!didPop && !_isVerifying) {
          widget.onError('Payment cancelled');
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Review'),
          backgroundColor: const Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          leading: _isVerifying
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    widget.onError('Payment cancelled');
                    Navigator.of(context).pop(false);
                  },
                ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading payment page...',
                        style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isVerifying)
              Container(
                color: Colors.black87,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Verifying payment...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
