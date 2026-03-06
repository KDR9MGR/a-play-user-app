
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaystackWebView extends StatefulWidget {
  final String authorizationUrl;
  final String reference;
  final Function(String) onSuccess;
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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (url.contains('payment-callback') ||
                url.contains('close') ||
                url.toLowerCase().contains('success')) {
              _verifyTransaction();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  Future<void> _verifyTransaction() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'paystack',
        body: {
          'action': 'verify',
          'reference': widget.reference,
        },
      );

      final responseData = (response.data as Map).cast<String, dynamic>();
      final data = (responseData['data'] as Map?)?.cast<String, dynamic>();

      if (response.status == 200 &&
          responseData['status'] == true &&
          data?['status'] == 'success') {
        widget.onSuccess(widget.reference);
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
            if (_isVerifying)
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
