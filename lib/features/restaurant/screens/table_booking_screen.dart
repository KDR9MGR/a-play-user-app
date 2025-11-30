import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controller/table_booking_controller.dart';
import '../model/restaurant_model.dart';
import '../model/restaurant_table_model.dart';
import '../model/restaurant_booking_model.dart';
import '../widgets/table_selection_widget.dart';
import '../widgets/time_slot_picker.dart';
import 'booking_confirmation_screen.dart';

class TableBookingScreen extends ConsumerStatefulWidget {
  final Restaurant restaurant;

  const TableBookingScreen({
    super.key,
    required this.restaurant,
  });

  @override
  ConsumerState<TableBookingScreen> createState() => _TableBookingScreenState();
}

class _TableBookingScreenState extends ConsumerState<TableBookingScreen> {
  final _pageController = PageController();
  final _specialRequestsController = TextEditingController();
  final _phoneController = TextEditingController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _specialRequestsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimeSlot = ref.watch(selectedTimeSlotProvider);
    final selectedTable = ref.watch(selectedTableProvider);
    final partySize = ref.watch(partySizeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Book a Table'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDateSelectionStep(),
                _buildTableSelectionStep(),
                _buildTimeSelectionStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep ? Colors.orange : Colors.grey[800],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateSelectionStep() {
    final selectedDate = ref.watch(selectedDateProvider);
    final partySize = ref.watch(partySizeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date & Party Size',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Party Size Selection
          const Text(
            'Party Size',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Dynamic party size based on table capacity
          ref.watch(restaurantTablesFamily(widget.restaurant.id)).when(
            data: (tables) {
              final maxCapacity = tables.isNotEmpty 
                  ? tables.map((table) => table.capacity).reduce((a, b) => a > b ? a : b)
                  : 8;
              final capacityOptions = maxCapacity > 8 ? maxCapacity : 8;
              
              return Row(
                children: List.generate(capacityOptions, (index) {
                  final size = index + 1;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(partySizeProvider.notifier).state = size;
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: index < capacityOptions - 1 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: partySize == size ? Colors.orange : Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: partySize == size ? Colors.orange : Colors.grey[700]!,
                          ),
                        ),
                        child: Text(
                          '$size',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: partySize == size ? Colors.white : Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
            error: (error, stack) {
              // Fallback to default 8 options if error
              return Row(
                children: List.generate(8, (index) {
                  final size = index + 1;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(partySizeProvider.notifier).state = size;
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: index < 7 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: partySize == size ? Colors.orange : Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: partySize == size ? Colors.orange : Colors.grey[700]!,
                          ),
                        ),
                        child: Text(
                          '$size',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: partySize == size ? Colors.white : Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
            loading: () {
              // Show loading placeholder with default 8 options
              return Row(
                children: List.generate(8, (index) {
                  final size = index + 1;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(partySizeProvider.notifier).state = size;
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: index < 7 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: partySize == size ? Colors.orange : Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: partySize == size ? Colors.orange : Colors.grey[700]!,
                          ),
                        ),
                        child: Text(
                          '$size',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: partySize == size ? Colors.white : Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Date Selection
          const Text(
            'Select Date',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Calendar Widget
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  surface: Colors.grey[900],
                  onSurface: Colors.white,
                  secondary: Colors.orange,
                  onSecondary: Colors.white,
                ),
                textTheme: Theme.of(context).textTheme.copyWith(
                  bodyLarge: const TextStyle(color: Colors.white),
                  bodyMedium: const TextStyle(color: Colors.white),
                  labelLarge: const TextStyle(color: Colors.white),
                  titleMedium: const TextStyle(color: Colors.white),
                  headlineSmall: const TextStyle(color: Colors.white),
                ),
              ),
              child: CalendarDatePicker(
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onDateChanged: (date) {
                  print('Date changed to: $date'); // Debug log
                  ref.read(selectedDateProvider.notifier).state = date;
                  // Reset dependent selections
                  ref.read(selectedTimeSlotProvider.notifier).state = null;
                  ref.read(selectedTableProvider.notifier).state = null;
                },
              ),
            ),
          ),
          
          // Show selected date for visual confirmation
          if (selectedDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Selected: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableSelectionStep() {
    final selectedDate = ref.watch(selectedDateProvider);
    final partySize = ref.watch(partySizeProvider);

    if (selectedDate == null) {
      return const Center(
        child: Text(
          'Please select a date first',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return TableSelectionWidget(
      restaurantId: widget.restaurant.id,
      date: selectedDate,
      minCapacity: partySize,
      onTableSelected: (table) {
        ref.read(selectedTableProvider.notifier).state = table;
        // Reset time slot selection
        ref.read(selectedTimeSlotProvider.notifier).state = null;
      },
    );
  }

  Widget _buildTimeSelectionStep() {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTable = ref.watch(selectedTableProvider);

    if (selectedDate == null || selectedTable == null) {
      return const Center(
        child: Text(
          'Please select a date and table first',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return TimeSlotPicker(
      restaurantId: widget.restaurant.id,
      tableId: selectedTable.id,
      date: selectedDate,
      onTimeSlotSelected: (timeSlot) {
        ref.read(selectedTimeSlotProvider.notifier).state = timeSlot;
      },
    );
  }

  Widget _buildConfirmationStep() {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimeSlot = ref.watch(selectedTimeSlotProvider);
    final selectedTable = ref.watch(selectedTableProvider);
    final partySize = ref.watch(partySizeProvider);

    if (selectedDate == null || selectedTimeSlot == null || selectedTable == null) {
      return const Center(
        child: Text(
          'Please complete previous steps',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Booking Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Restaurant', widget.restaurant.name),
                _buildSummaryRow('Date', DateFormat('MMM dd, yyyy').format(selectedDate)),
                _buildSummaryRow('Time', '${DateFormat('h:mm a').format(selectedTimeSlot.startTime)} - ${DateFormat('h:mm a').format(selectedTimeSlot.endTime)}'),
                _buildSummaryRow('Table', '${selectedTable.tableNumber} (${selectedTable.tableType.displayName})'),
                _buildSummaryRow('Capacity', '${selectedTable.capacity} people'),
                _buildSummaryRow('Party Size', '$partySize people'),
                if (selectedTable.locationDescription != null)
                  _buildSummaryRow('Location', selectedTable.locationDescription!),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Special Requests
          const Text(
            'Special Requests (Optional)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _specialRequestsController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any special requests or preferences...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Contact Phone
          const Text(
            'Contact Phone',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Your contact number',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimeSlot = ref.watch(selectedTimeSlotProvider);
    final selectedTable = ref.watch(selectedTableProvider);
    final bookingState = ref.watch(tableBookingProvider);

    bool canProceed = false;
    String buttonText = 'Next';

    switch (_currentStep) {
      case 0:
        canProceed = selectedDate != null;
        break;
      case 1:
        canProceed = selectedTable != null;
        break;
      case 2:
        canProceed = selectedTimeSlot != null;
        break;
      case 3:
        canProceed = true;
        buttonText = 'Confirm Booking';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: canProceed ? () {
                if (_currentStep == 3) {
                  _confirmBooking();
                } else {
                  _nextStep();
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: bookingState.isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    buttonText,
                    style: const TextStyle(
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

  Future<void> _confirmBooking() async {
    final selectedDate = ref.read(selectedDateProvider)!;
    final selectedTimeSlot = ref.read(selectedTimeSlotProvider)!;
    final selectedTable = ref.read(selectedTableProvider)!;
    final partySize = ref.read(partySizeProvider);

    try {
      final booking = await ref.read(tableBookingProvider.notifier).createBooking(
        restaurantId: widget.restaurant.id,
        tableId: selectedTable.id,
        bookingDate: selectedDate,
        startTime: selectedTimeSlot.startTime,
        endTime: selectedTimeSlot.endTime,
        partySize: partySize,
        specialRequests: _specialRequestsController.text.isNotEmpty 
          ? _specialRequestsController.text 
          : null,
        contactPhone: _phoneController.text.isNotEmpty 
          ? _phoneController.text 
          : null,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              booking: booking,
              restaurant: widget.restaurant,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}