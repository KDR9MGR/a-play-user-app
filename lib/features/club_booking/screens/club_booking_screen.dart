import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/club_booking/provider/club_booking_provider.dart';
import 'package:a_play/features/club_booking/model/table_model.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ClubBookingScreen extends ConsumerStatefulWidget {
  final String clubId;

  const ClubBookingScreen({
    super.key,
    required this.clubId,
  });

  @override
  ConsumerState<ClubBookingScreen> createState() => _ClubBookingScreenState();
}

class _ClubBookingScreenState extends ConsumerState<ClubBookingScreen> {
  String? _selectedTableId;
  double _totalPrice = 0.0;
  bool _isBookingConfirmed = false;

  @override
  void initState() {
    super.initState();
    // Load club details and tables
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clubDetailsControllerProvider.notifier).loadClubDetails(widget.clubId);
      ref.read(clubTablesControllerProvider.notifier).loadClubTables(widget.clubId);
    });
  }

  void _calculateTotalPrice() {
    final tables = ref.read(clubTablesControllerProvider).valueOrNull ?? [];
    final selectedTable = tables.firstWhere(
      (table) => table.id == _selectedTableId,
      orElse: () => const TableModel(
        id: '',
        clubId: '',
        name: '',
        capacity: 0,
        isAvailable: false,
        pricePerHour: 0,
      ),
    );
    
    final timeRange = ref.read(timeRangeProvider);
    final hours = timeRange.$2.difference(timeRange.$1).inMinutes / 60.0;
    _totalPrice = selectedTable.pricePerHour * hours;
    setState(() {});
  }

  void _submitBooking() {
    if (_selectedTableId == null) return;
    
    final selectedDate = ref.read(selectedDateProvider);
    final timeRange = ref.read(timeRangeProvider);
    
    _calculateTotalPrice();
    
    ref.read(bookingControllerProvider.notifier).createBooking(
      clubId: widget.clubId,
      tableId: _selectedTableId!,
      bookingDate: selectedDate,
      startTime: timeRange.$1,
      endTime: timeRange.$2,
      totalPrice: _totalPrice,
    );
    
    setState(() {
      _isBookingConfirmed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubDetails = ref.watch(clubDetailsControllerProvider);
    final tables = ref.watch(clubTablesControllerProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final timeRange = ref.watch(timeRangeProvider);
    final booking = ref.watch(bookingControllerProvider);
    final formattedDate = DateFormat('EEE, d MMMM').format(selectedDate);
    final formattedTime = '${DateFormat('h:mm a').format(timeRange.$1)} - ${DateFormat('h:mm a').format(timeRange.$2)}';
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a Table',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            clubDetails.when(
              data: (club) => Text(
                club?.name ?? '',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Booking Details Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade900,
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 18, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: _isBookingConfirmed
                ? _buildBookingConfirmation(booking)
                : _buildTableSelectionContent(tables, selectedDate, timeRange),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTableSelectionContent(
    AsyncValue<List<TableModel>> tables,
    DateTime selectedDate,
    (DateTime, DateTime) timeRange,
  ) {
    return Column(
      children: [
        // Tables Section
        Expanded(
          child: tables.when(
            data: (tablesList) {
              if (tablesList.isEmpty) {
                return const Center(
                  child: Text(
                    'No tables available for this club',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tablesList.length,
                itemBuilder: (context, index) {
                  final table = tablesList[index];
                  final isSelected = _selectedTableId == table.id;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                          : Border.all(color: Colors.grey.shade800, width: 1),
                    ),
                    child: InkWell(
                      onTap: table.isAvailable
                          ? () {
                              setState(() {
                                _selectedTableId = table.id;
                                _calculateTotalPrice();
                              });
                            }
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Table Icon
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.table_bar,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${table.capacity}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Table Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    table.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Location: ${table.location ?? 'Main Floor'}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${table.pricePerHour.toStringAsFixed(2)} / hour',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Selection Indicator
                            if (table.isAvailable)
                              Icon(
                                isSelected 
                                  ? Icons.radio_button_checked 
                                  : Icons.radio_button_unchecked,
                                color: isSelected 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.white,
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.red),
                                ),
                                child: const Text(
                                  'Unavailable',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error loading tables: $error',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        
        // Bottom Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // Price Display
              if (_selectedTableId != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Price:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${_totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedTableId != null ? _submitBooking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingConfirmation(AsyncValue<dynamic> booking) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          booking.when(
            data: (bookingData) => _buildSuccessContent(bookingData),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorContent(error),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessContent(dynamic bookingData) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.green,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Booking Confirmed!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your table has been reserved successfully.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildDetailRow('Booking ID', bookingData?.id ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Date & Time',
                '${DateFormat('EEE, d MMM').format(ref.read(selectedDateProvider))}, ${DateFormat('h:mm a').format(ref.read(timeRangeProvider).$1)} - ${DateFormat('h:mm a').format(ref.read(timeRangeProvider).$2)}',
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Price', '\$${_totalPrice.toStringAsFixed(2)}'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Return to Home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(dynamic error) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Booking Failed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Error: ${error.toString()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isBookingConfirmed = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
} 