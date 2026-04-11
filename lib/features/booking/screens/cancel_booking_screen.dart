import 'package:a_play/core/constants/colors.dart';
import 'package:a_play/data/models/booking_model.dart';
import 'package:a_play/features/booking/providers/bookin_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class CancelBookingScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const CancelBookingScreen({
    super.key,
    required this.booking,
  });

  @override
  ConsumerState<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends ConsumerState<CancelBookingScreen> {
  final _reasonController = TextEditingController();
  String? _selectedReason;
  bool _isProcessing = false;

  final List<String> _cancellationReasons = [
    'Change of plans',
    'Found a better event',
    'Emergency situation',
    'Event timing conflict',
    'Travel issues',
    'Medical reasons',
    'Financial reasons',
    'Other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Calculate refund amount based on cancellation policy
  Map<String, dynamic> _calculateRefund() {
    final eventDate = DateTime.parse(widget.booking.eventEndDate);
    final now = DateTime.now();
    final hoursUntilEvent = eventDate.difference(now).inHours;

    double refundPercentage = 0.0;
    String refundPolicy = '';

    if (hoursUntilEvent >= 48) {
      // More than 48 hours: Full refund
      refundPercentage = 1.0;
      refundPolicy = 'Full refund (100%)';
    } else if (hoursUntilEvent >= 24) {
      // 24-48 hours: 50% refund
      refundPercentage = 0.5;
      refundPolicy = 'Partial refund (50%)';
    } else if (hoursUntilEvent > 0) {
      // Less than 24 hours: No refund
      refundPercentage = 0.0;
      refundPolicy = 'No refund';
    } else {
      // Event already started or passed
      refundPercentage = 0.0;
      refundPolicy = 'Event already started - No refund';
    }

    final ticketPrice = widget.booking.amount ?? 0.0;
    final serviceFee = ticketPrice * 0.029 + 1; // PayStack fee: 2.9% + GHS 1
    final refundAmount = (ticketPrice - serviceFee) * refundPercentage;

    return {
      'percentage': refundPercentage,
      'amount': refundAmount,
      'policy': refundPolicy,
      'hoursUntilEvent': hoursUntilEvent,
      'serviceFee': serviceFee,
    };
  }

  Future<void> _submitCancellation() async {
    // Validate reason
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a cancellation reason'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedReason == 'Other' && _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for cancellation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Confirm Cancellation'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final bookingService = ref.read(bookingServiceProvider);
      final reason = _selectedReason == 'Other'
          ? _reasonController.text.trim()
          : _selectedReason!;

      await bookingService.cancelBooking(
        bookingId: widget.booking.id!,
        reason: reason,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cancellation request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back and refresh bookings
      if (mounted) {
        context.go('/my-tickets');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final refundInfo = _calculateRefund();
    final canCancel = refundInfo['hoursUntilEvent'] > 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Cancel Booking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Banner
            if (!canCancel)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade700),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.warning_2, color: Colors.red.shade400, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This event has already started. Cancellations are no longer available.',
                        style: TextStyle(
                          color: Colors.red.shade200,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Booking Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.calendar, color: AppColors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Booking Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Event', widget.booking.eventTitle),
                  _buildDetailRow(
                    'Date',
                    DateFormat('EEE, MMM d, yyyy').format(
                      DateTime.parse(widget.booking.eventEndDate),
                    ),
                  ),
                  _buildDetailRow('Booking ID', widget.booking.id ?? 'N/A'),
                  _buildDetailRow(
                    'Total Paid',
                    'GHS ${widget.booking.amount?.toStringAsFixed(2) ?? '0.00'}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Refund Policy Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.orange.withOpacity(0.1),
                    AppColors.orange.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.info_circle, color: AppColors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Refund Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRefundRow(
                    'Time Until Event',
                    '${refundInfo['hoursUntilEvent']} hours',
                  ),
                  _buildRefundRow(
                    'Refund Policy',
                    refundInfo['policy'],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Refund Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'GHS ${refundInfo['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: refundInfo['amount'] > 0
                              ? Colors.green
                              : Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                  if (refundInfo['serviceFee'] > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Service fee (GHS ${refundInfo['serviceFee'].toStringAsFixed(2)}) is non-refundable',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (canCancel) ...[
              const SizedBox(height: 24),

              // Cancellation Reason
              const Text(
                'Reason for Cancellation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Reason Dropdown
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedReason,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                    hintText: 'Select a reason',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  dropdownColor: AppColors.cardDark,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: _cancellationReasons.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                ),
              ),

              // Additional Details (if "Other" selected)
              if (_selectedReason == 'Other') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _reasonController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Please provide more details...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: AppColors.cardDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.orange),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Policy Agreement
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.info_circle, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Refunds are processed within 5-7 business days to your original payment method. Processing fees are non-refundable.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: canCancel
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _submitCancellation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Cancellation Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
