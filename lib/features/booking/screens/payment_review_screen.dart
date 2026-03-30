import 'dart:async';
import 'package:a_play/data/models/event_model.dart';
import 'package:a_play/features/widgets/squircle_container.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/core/constants/app_constants.dart';
import 'package:a_play/features/booking/service/booking_service.dart';
import 'package:a_play/core/constants/colors.dart';
import 'package:a_play/services/unified_payment_service.dart';
import 'package:a_play/features/booking/screens/zone_selection_screen.dart';
import 'package:go_router/go_router.dart';

// Provider for BookingService
final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

// Provider for loading state
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for error state
final errorProvider = StateProvider<String?>((ref) => null);

// Provider for Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider for user premium status
final isUserPremiumProvider = FutureProvider<bool>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return false;

  try {
    final response = await supabase
        .from('profiles')
        .select('is_premium')
        .eq('id', user.id)
        .single();

    return response['is_premium'] ?? false;
  } catch (e) {
    debugPrint('Error fetching premium status: $e');
    return false;
  }
});

class PaymentReviewScreen extends ConsumerStatefulWidget {
  final EventModel event;
  final DateTime selectedDate;
  final List<TicketSelection> selectedTickets;
  final double totalAmount;

  const PaymentReviewScreen({
    super.key,
    required this.event,
    required this.selectedDate,
    required this.selectedTickets,
    required this.totalAmount,
  });

  @override
  ConsumerState<PaymentReviewScreen> createState() =>
      _PaymentReviewScreenState();
}

class _PaymentReviewScreenState extends ConsumerState<PaymentReviewScreen> {
  Timer? _timer;
  int _timeLeft = 300; // 5 minutes in seconds
  String _reference = '';

  @override
  void initState() {
    super.initState();
    _startDater();
    _reference = 'aplay_${DateTime.now().millisecondsSinceEpoch}';
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
          Navigator.of(context).pop();
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _handlePaymentError(BuildContext context, String error) {
    if (!mounted) return;

    debugPrint('Payment error details: $error');

    String userMessage;
    String actionMessage;

    if (error.toLowerCase().contains('network')) {
      userMessage = 'Please check your internet connection and try again.';
      actionMessage = 'Retry';
    } else if (error.toLowerCase().contains('insufficient')) {
      userMessage =
          'Insufficient funds. Please try a different payment method.';
      actionMessage = 'Try Again';
    } else if (error.toLowerCase().contains('timeout')) {
      userMessage = 'The payment process took too long. Please try again.';
      actionMessage = 'Retry';
    } else if (error.toLowerCase().contains('cancelled')) {
      userMessage = 'Payment was cancelled. Please try again when ready.';
      actionMessage = 'Try Again';
    } else if (error.toLowerCase().contains('invalid')) {
      userMessage = 'Payment details are invalid. Please check and try again.';
      actionMessage = 'Update Details';
    } else {
      userMessage = 'There was an unexpected error processing your payment.';
      actionMessage = 'Try Again';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 48,
        ),
        title: const Text(
          'Payment Failed',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userMessage,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_outlined,
                    color: Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reference: $_reference',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPayment(); // Retry the payment
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              actionMessage,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    final supabase = ref.read(supabaseProvider);
    final user = supabase.auth.currentUser;

    if (user == null || user.email == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to continue')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => ref.read(isLoadingProvider.notifier).state = true);

    try {
      final isUserPremium = await ref.read(isUserPremiumProvider.future);
      final finalAmount =
          isUserPremium ? widget.totalAmount : widget.totalAmount * 2;

      HapticFeedback.mediumImpact();

      if (!mounted) return;

      // Initialize payment service
      final paymentService = UnifiedPaymentService.instance;

      // Process payment with WebView
      final success = await paymentService.processPayment(
        context: context,
        email: user.email!,
        amount: finalAmount,
        reference: _reference,
        metadata: {
          'event_id': widget.event.id,
          'selected_tickets': widget.selectedTickets
              .map((ticket) => {
                    'zoneId': ticket.zoneId,
                    'quantity': ticket.quantity,
                    'amount': ticket.price * ticket.quantity,
                  })
              .toList(),
          'selected_date': widget.selectedDate.toIso8601String(),
          'is_premium_user': isUserPremium,
          'user_id': user.id,
        },
        onSuccess: () async {
          try {
            debugPrint('Payment successful, processing booking...');

            if (!mounted) return;
            final bookingService = ref.read(bookingServiceProvider);
            final bookingIds = await bookingService.createBookings(
              eventId: widget.event.id,
              bookingDate: widget.selectedDate.toIso8601String(),
              eventDate: widget.selectedDate,
              tickets: widget.selectedTickets
                  .map((ticket) => {
                        'zoneId': ticket.zoneId,
                        'quantity': ticket.quantity,
                        'amount': ticket.price * ticket.quantity,
                      })
                  .toList(),
            );

            debugPrint('Booking processed successfully');

            if (!mounted) return;

            // Use GoRouter for navigation
            context.go('/booking-confirmation/${bookingIds.first['id']}');
          } catch (e) {
            debugPrint('Error processing booking: $e');
            if (!mounted) return;
            _handlePaymentError(context, e.toString());
          }
        },
        onError: (error) {
          debugPrint('Payment error: $error');
          if (!mounted) return;
          _handlePaymentError(context, error);
        },
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment was cancelled'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Payment process error: $e');
      if (!mounted) return;
      _handlePaymentError(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => ref.read(isLoadingProvider.notifier).state = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final isUserPremiumAsync = ref.watch(isUserPremiumProvider);

    return isUserPremiumAsync.when(
      data: (isUserPremium) {
        final finalAmount =
            isUserPremium ? widget.totalAmount : widget.totalAmount * 2;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment Review'),
                Text(
                  _formatTime(_timeLeft),
                  style: TextStyle(
                    color: _timeLeft < 60 ? Colors.red : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          //Event Cover image
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(widget.event.coverImage),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(widget.event.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                                Text(widget.event.location, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),),

                              ],
                            ),
                          ],
                        ),
                     
                      ),
                      if (!isUserPremium)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber[900]?.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.amber[700]!, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star,
                                  color: Colors.amber[700], size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Premium User Benefits',
                                      style: TextStyle(
                                        color: Colors.amber[700],
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Upgrade to premium to get 50% off on all ticket purchases!',
                                      style: TextStyle(
                                        color: Colors.amber[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      SquircleContainer(
                        radius: 45,
                        
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                           
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Summary',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...widget.selectedTickets
                                  .map((ticket) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${ticket.zoneName} × ${ticket.quantity}',
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${AppConstants.currency} ${(ticket.price * ticket.quantity).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  ,
                              if (!isUserPremium) ...[
                                const DottedLine(dashColor: Colors.grey, dashRadius: 2, dashGapLength: 4, dashLength: 4, lineThickness: 1,),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Non-Premium Fee (2x)',
                                      style: TextStyle(
                                        color: Colors.amber[700],
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '+${AppConstants.currency} ${widget.totalAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.amber[700],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const DottedLine(dashColor: Colors.grey, dashRadius: 2, dashGapLength: 4, dashLength: 4, lineThickness: 1,),
                              const Gap(10),
                              
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
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        AppConstants.currency,
                                        style: GoogleFonts.outfit(
                                          color: Colors.grey[400],
                                          height: 1.8,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Gap(4),
                                      Text(
                                        finalAmount.toStringAsFixed(2),
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: isLoading ? null : _processPayment,
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
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
