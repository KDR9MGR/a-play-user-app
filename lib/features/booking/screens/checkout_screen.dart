import 'dart:async';
import 'package:a_play/features/booking/model/zoneModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/core/constants/colors.dart';
import 'package:a_play/features/home/model/event_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:a_play/core/constants/app_constants.dart';

final userProvider = StreamProvider<DocumentSnapshot>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');
  return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
});

class CheckoutScreen extends ConsumerStatefulWidget {
  final EventModel event;
  final ZoneModel zone;
  final int ticketCount;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.event,
    required this.zone,
    required this.ticketCount,
    required this.totalAmount,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool isLoading = false;
  Timer? _timer;
  int _timeLeft = 300; // 5 minutes in seconds

  @override
  void initState() {
    super.initState();
    _startDater();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDater() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.of(context)
              .pop(); // Return to previous screen when time expires
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double calculateTotal(bool isPremium) {
    final basePrice = widget.totalAmount;
    return isPremium ? basePrice * 2 : basePrice;
  }

  Future<void> initializePayment(double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please update your email in profile settings')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final secretKey = dotenv.env['PAYSTACK_SECRET_KEY'];
      final publicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'];
      if (secretKey == null || publicKey == null) {
        throw Exception('Paystack keys not found in environment variables');
      }

      final email = user.email;
      final reference = 'aplay_${DateTime.now().millisecondsSinceEpoch}';

      debugPrint(
          'Initializing payment for amount: ${(amount * 100).round()} kobo');

      // Initialize transaction
      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'amount': (amount * 100).round(), // Convert to kobo
          'reference': reference,
          'callback_url': 'aplay://payment-callback',
          'metadata': {
            'event_id': widget.event.id,
            'zone': widget.zone.name,
            'ticket_count': widget.ticketCount,
            'date': DateFormat('yyyy-MM-dd').format(widget.event.startDate),
            'custom_fields': [
              {
                'display_name': 'EventModel',
                'variable_name': 'event',
                'value': widget.event.title
              },
              {
                'display_name': 'Zone',
                'variable_name': 'zone',
                'value': widget.zone.name
              }
            ]
          },
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['status'] == true) {
        final authorizationUrl = responseData['data']['authorization_url'];

        // Navigate to WebView for payment
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaystackWebView(
                authorizationUrl: authorizationUrl,
                reference: reference,
                secretKey: secretKey,
                onSuccess: () async {
                  try {
                    final bookingId = await _saveBooking();
                    if (mounted) {
                      // Replace all screens with the ticket screen
                      // Navigator.of(context).pushAndRemoveUntil(
                      //   MaterialPageRoute(
                      //     builder: (context) => TicketSuccessScreen(
                      //       event: widget.event,
                      //       zone: widget.zone,
                      //       ticketCount: widget.ticketCount,
                      //       bookingId: bookingId,
                      //       totalAmount: widget.totalAmount,
                      //     ),
                      //   ),
                      //   (route) => route.isFirst, // Keep only the first route
                      // );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving booking: $e')),
                      );
                    }
                  }
                },
                onError: (message) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment failed: $message'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.of(context)
                        .pop(false); // Return to checkout screen
                  }
                },
              ),
            ),
          );
        }
      } else {
        throw Exception(
            responseData['message'] ?? 'Payment initialization failed');
      }
    } catch (e) {
      debugPrint('Payment Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<String> _saveBooking() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final booking = {
      'eventId': widget.event.id,
      'userId': userId,
      'zone': widget.zone.name,
      'ticketCount': widget.ticketCount,
      'status': 'confirmed',
      'date': widget.event.startDate,
      'createdAt': FieldValue.serverTimestamp(),
      'totalAmount': calculateTotal(
          ref.read(userProvider).value?.get('isPremium') ?? false),
    };

    // Create booking
    final docRef =
        await FirebaseFirestore.instance.collection('bookings').add(booking);
    return docRef.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Timer Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[800]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completing booking: ${_formatTime(_timeLeft)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // EventModel Image and Basic Info
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.event.coverImage,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // EventModel Details
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEE, MMM d, y')
                            .format(widget.event.startDate),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900]?.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[800]!.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.zone.name} × ${widget.ticketCount}',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${AppConstants.currency}${widget.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: Colors.white24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${AppConstants.currency}${widget.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Payment Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: isLoading
                  ? null
                  : () => initializePayment(widget.totalAmount),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Pay with Paystack',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

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
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() => _isLoading = true);
              debugPrint('Page started loading: $url');
            },
            onPageFinished: (String url) {
              setState(() => _isLoading = false);
              debugPrint('Page finished loading: $url');

              if (url.contains('payment-callback')) {
                _verifyTransaction();
              }
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView error: ${error.description}');
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
                _isLoading = false;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.authorizationUrl));
    } catch (e) {
      debugPrint('Error initializing WebView: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyTransaction() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.paystack.co/transaction/verify/${widget.reference}'),
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
        final message = responseData['data']['gateway_response'] ??
            responseData['message'] ??
            'Payment verification failed';
        widget.onError(message);
        if (mounted) {
          Navigator.of(context).pop(false);
        }
      }
    } catch (e) {
      debugPrint('Verification Error: $e');
      widget.onError(e.toString());
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          leading: CloseButton(
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading payment page',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = '';
                    _isLoading = true;
                  });
                  _initializeWebView();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: CloseButton(
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
