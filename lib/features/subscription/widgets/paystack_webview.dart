import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class PaystackWebView extends StatefulWidget {
  final String authorizationUrl;
  final String reference;
  final String secretKey;
  final VoidCallback onSuccess;
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
  State<PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _checkPaymentStatus(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkPaymentStatus(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            widget.onError('Payment error: ${error.description}');
            if (mounted) {
              Navigator.of(context).pop(false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  void _checkPaymentStatus(String url) {
    if (_isVerifying) return;

    if (url.contains('payment-callback') || 
        url.contains('close') || 
        url.toLowerCase().contains('success')) {
      _verifyTransaction();
    }
  }

  Future<void> _verifyTransaction() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/${widget.reference}'),
        headers: {
          'Authorization': 'Bearer ${widget.secretKey}',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && 
          responseData['status'] == true && 
          responseData['data']['status'] == 'success') {
        widget.onSuccess();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Payment verification failed');
      }
    } catch (e) {
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
    return WillPopScope(
      onWillPop: () async {
        widget.onError('Payment cancelled');
        Navigator.of(context).pop(false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          leading: _isVerifying
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    widget.onError('Payment cancelled');
                  },
                ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading || _isVerifying)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}