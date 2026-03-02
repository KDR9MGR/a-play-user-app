import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controller/table_booking_controller.dart';
import '../model/restaurant_booking_model.dart';

class TimeSlotPicker extends ConsumerWidget {
  final String restaurantId;
  final String tableId;
  final DateTime date;
  final Function(BookingTimeSlot) onTimeSlotSelected;

  const TimeSlotPicker({
    super.key,
    required this.restaurantId,
    required this.tableId,
    required this.date,
    required this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeSlotsAsync = ref.watch(timeSlotsFamily(TimeSlotsParams(
      restaurantId: restaurantId,
      tableId: tableId,
      date: date,
    )));
    final selectedTimeSlot = ref.watch(selectedTimeSlotProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred dining time',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: timeSlotsAsync.when(
              data: (timeSlots) {
                if (timeSlots.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No time slots available',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    final timeSlot = timeSlots[index];
                    final isSelected = selectedTimeSlot?.startTime == timeSlot.startTime;
                    final isPastTime = timeSlot.startTime.isBefore(DateTime.now());
                    final isAvailable = timeSlot.isAvailable && !isPastTime;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: isAvailable ? () {
                          onTimeSlotSelected(timeSlot);
                        } : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.orange.withValues(alpha: 0.2)
                                : isAvailable 
                                    ? Colors.grey[800]
                                    : Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.orange
                                  : isAvailable 
                                      ? Colors.grey[700]!
                                      : Colors.grey[800]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: isSelected 
                                    ? Colors.orange
                                    : isAvailable 
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat('h:mm a').format(timeSlot.startTime)} - ${DateFormat('h:mm a').format(timeSlot.endTime)}',
                                      style: TextStyle(
                                        color: isSelected 
                                            ? Colors.orange
                                            : isAvailable 
                                                ? Colors.white
                                                : Colors.grey[500],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getTimeSlotDescription(timeSlot, isPastTime),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              if (!isAvailable)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPastTime 
                                        ? Colors.grey[700]
                                        : Colors.red[900],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isPastTime ? 'Past' : 'Booked',
                                    style: TextStyle(
                                      color: isPastTime 
                                          ? Colors.grey[400]
                                          : Colors.red[300],
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              else if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
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
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load time slots',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeSlotDescription(BookingTimeSlot timeSlot, bool isPastTime) {
    if (isPastTime) {
      return 'This time has passed';
    }
    
    if (!timeSlot.isAvailable) {
      return timeSlot.unavailableReason ?? 'Not available';
    }

    final startHour = timeSlot.startTime.hour;
    if (startHour < 12) {
      return 'Breakfast/Brunch time';
    } else if (startHour < 17) {
      return 'Lunch time';
    } else {
      return 'Dinner time';
    }
  }
}