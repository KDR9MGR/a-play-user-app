import 'package:a_play/data/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/core/constants/app_constants.dart';
import 'package:a_play/features/booking/screens/payment_review_screen.dart';
import 'package:a_play/features/booking/providers/zone_provider.dart';
import 'package:intl/intl.dart';

// Provider for selected date
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

// Provider for selected tickets
class TicketSelection {
  final String zoneId;
  final String zoneName;
  final double price;
  final int quantity;

  TicketSelection({
    required this.zoneId,
    required this.zoneName,
    required this.price,
    required this.quantity,
  });

  // Add a zone getter to match what payment_review_screen expects
  Map<String, dynamic> get zone => {
    'id': zoneId,
    'name': zoneName,
  };

  double get total => price * quantity;
}

final selectedTicketsProvider = StateProvider<List<TicketSelection>>((ref) => []);

class ZoneSelectionScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const ZoneSelectionScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<ZoneSelectionScreen> createState() => _ZoneSelectionScreenState();
}

class _ZoneSelectionScreenState extends ConsumerState<ZoneSelectionScreen> {
  @override
  void initState() {
    super.initState();
    _initializeSelectedDate();
    _validateEventDates();
  }

  void _validateEventDates() {
    print('Event Start Time: ${widget.event.startDate}');
    print('Event End Time: ${widget.event.endDate}');
    print('Number of days: ${widget.event.endDate.difference(widget.event.startDate).inDays}');
    
    if (widget.event.startDate.isAfter(widget.event.endDate)) {
      print('Warning: Event start time is after end time');
    }
  }

  void _initializeSelectedDate() {
    if (ref.read(selectedDateProvider) == null) {
      Future.microtask(() {
        ref.read(selectedDateProvider.notifier).state = widget.event.startDate;
        print('Selected Date Initialized: ${widget.event.startDate}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider) ?? widget.event.startDate;
    final selectedTickets = ref.watch(selectedTicketsProvider);
    final zones = ref.watch(eventZonesProvider((eventId: widget.event.id, date: selectedDate)));
    final totalAmount = selectedTickets.fold<double>(0, (sum, ticket) => sum + ticket.total);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${DateFormat('d MMM').format(widget.event.startDate)} - ${DateFormat('d MMM').format(widget.event.endDate)} | ${DateFormat('hh:mm a').format(widget.event.startDate)} onwards | ${widget.event.location}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Text(
              'Choose date',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Date Selection
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (int i = 0; i <= widget.event.endDate.difference(widget.event.startDate).inDays; i++)
                  _buildDateCard(
                    widget.event.startDate.add(Duration(days: i)),
                    selectedDate,
                  ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Text(
              'Choose tickets',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tickets List
          Expanded(
            child: zones.when(
              data: (zonesList) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: zonesList.length,
                itemBuilder: (context, index) {
                  final zone = zonesList[index];
                  // Safe type casting to prevent iPad crash (Apple Review fix)
                  final zoneId = zone['zone_id']?.toString() ?? 'zone_$index';
                  final zoneName = zone['name']?.toString() ?? 'Zone ${index + 1}';
                  final price = ((zone['price'] as num?) ?? 0).toDouble();
                  final available = (zone['available'] as int?) ?? 0;

                  final selectedQuantity = selectedTickets
                      .firstWhere(
                        (ticket) => ticket.zoneId == zoneId,
                        orElse: () => TicketSelection(
                          zoneId: zoneId,
                          zoneName: zoneName,
                          price: price,
                          quantity: 0,
                        ),
                      )
                      .quantity;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              zoneName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${AppConstants.currency} ${price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Admits one guest.',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'This ticket provides access to the event.',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        if (available > 0) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (selectedQuantity > 0) ...[
                                IconButton(
                                  onPressed: () {
                                    final currentTickets = List<TicketSelection>.from(
                                        ref.read(selectedTicketsProvider));
                                    final index = currentTickets
                                        .indexWhere((ticket) => ticket.zoneId == zoneId);
                                    if (index != -1) {
                                      if (currentTickets[index].quantity > 1) {
                                        currentTickets[index] = TicketSelection(
                                          zoneId: zoneId,
                                          zoneName: zoneName,
                                          price: price,
                                          quantity: currentTickets[index].quantity - 1,
                                        );
                                      } else {
                                        currentTickets.removeAt(index);
                                      }
                                      ref.read(selectedTicketsProvider.notifier).state =
                                          currentTickets;
                                    }
                                  },
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white),
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    selectedQuantity.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              IconButton(
                                onPressed: selectedQuantity < available
                                    ? () {
                                        final currentTickets = List<TicketSelection>.from(
                                            ref.read(selectedTicketsProvider));
                                        final index = currentTickets
                                            .indexWhere((ticket) => ticket.zoneId == zoneId);
                                        if (index != -1) {
                                          currentTickets[index] = TicketSelection(
                                            zoneId: zoneId,
                                            zoneName: zoneName,
                                            price: price,
                                            quantity: currentTickets[index].quantity + 1,
                                          );
                                        } else {
                                          currentTickets.add(TicketSelection(
                                            zoneId: zoneId,
                                            zoneName: zoneName,
                                            price: price,
                                            quantity: 1,
                                          ));
                                        }
                                        ref.read(selectedTicketsProvider.notifier).state =
                                            currentTickets;
                                      }
                                    : null,
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              if (selectedQuantity == 0)
                                TextButton(
                                  onPressed: () {
                                    final currentTickets = List<TicketSelection>.from(
                                        ref.read(selectedTicketsProvider));
                                    currentTickets.add(TicketSelection(
                                      zoneId: zoneId,
                                      zoneName: zoneName,
                                      price: price,
                                      quantity: 1,
                                    ));
                                    ref.read(selectedTicketsProvider.notifier).state =
                                        currentTickets;
                                  },
                                  child: const Text(
                                    'Add',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          // Bottom Bar
          if (selectedTickets.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${selectedTickets.fold<int>(0, (sum, ticket) => sum + ticket.quantity)} ticket${selectedTickets.fold<int>(0, (sum, ticket) => sum + ticket.quantity) > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${AppConstants.currency} ${totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentReviewScreen(
                            event: widget.event,
                            selectedTickets: selectedTickets,
                            selectedDate: selectedDate,
                            totalAmount: totalAmount,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateCard(DateTime date, DateTime selectedDate) {
    final isSelected = date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;

    print('Building date card for: ${date.toString()}');

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(selectedDateProvider.notifier).state = date;
        print('Date selected: ${date.toString()}');
      },
      child: Container(
        width: 64,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('E').format(date),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
  
