import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/core/widgets/sign_in_dialog.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import 'package:a_play/features/home/model/club_model.dart';
import 'package:a_play/features/club_booking/provider/club_booking_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:a_play/core/theme/app_colors.dart';


class ClubDetailsScreen extends ConsumerStatefulWidget {
  final Club club;

  const ClubDetailsScreen({
    super.key,
    required this.club,
  });

  @override
  ConsumerState<ClubDetailsScreen> createState() => _ClubDetailsScreenState();
}

class _ClubDetailsScreenState extends ConsumerState<ClubDetailsScreen> {
  int _selectedGuests = 2;
  DateTime _selectedDate = DateTime.now();
  String _selectedMeal = 'Dinner';
  String? _selectedTime;
  
  final List<String> _mealOptions = ['Lunch', 'Dinner'];
  final List<String> _timeSlots = [
    '12:00 PM', '12:30 PM', '1:00 PM', 
    '1:30 PM', '2:00 PM', '2:30 PM',
    '7:00 PM', '7:30 PM', '8:00 PM',
    '8:30 PM', '9:00 PM', '9:30 PM'
  ];
  
  @override
  void initState() {
    super.initState();
    // Load club details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clubDetailsControllerProvider.notifier).loadClubDetails(widget.club.id);
    });
  }

  List<DateTime> _getNextSevenDays() {
    final List<DateTime> dates = [];
    final DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    return dates;
  }
  
  // Convert time string to DateTime
  DateTime _parseTimeString(String timeString) {
    final format = DateFormat('h:mm a');
    final time = format.parse(timeString);
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clubDetails = ref.watch(clubDetailsControllerProvider);
    final dates = _getNextSevenDays();
    
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
              'Book a table',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.club.name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guest Selection
            _buildSelectionCard(
              title: 'Select number of guests',
              child: DropdownButton<int>(
                value: _selectedGuests,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                underline: Container(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedGuests = newValue;
                    });
                  }
                },
                items: List.generate(10, (index) => index + 1)
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Date Selection
            const Text(
              'Select day and time',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Date Picker
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected = _selectedDate.day == date.day && 
                                    _selectedDate.month == date.month;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? const LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ) : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (index == 0)
                            Text(
                              'Today',
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            Text(
                              DateFormat('E').format(date), // Day name (Mon, Tue, etc.)
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(date), // Day number
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Meal Type Selection
            Row(
              children: _mealOptions.map((meal) {
                final isSelected = _selectedMeal == meal;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMeal = meal;
                      _selectedTime = null; // Reset time when meal changes
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: isSelected ? const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ) : null,
                      border: !isSelected ? Border.all(
                        color: Colors.white24,
                        width: 1,
                      ) : null,
                    ),
                    child: Text(
                      meal,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Time Slots
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getTimeSlotsByMeal().map((timeSlot) {
                final isSelected = _selectedTime == timeSlot;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = timeSlot;
                    });
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 48) / 3,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: AppColors.primaryGradient[0], width: 2) : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          timeSlot,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '1 offer',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const Spacer(),
            
            // Proceed Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTime != null ? () async {
                  // CRITICAL: Check if user is authenticated before allowing club booking
                  // This prevents crashes when guest users try to book clubs
                  final user = ref.read(authStateProvider).value;

                  if (user == null) {
                    // Show sign-in dialog for guest users
                    final signedIn = await SignInDialog.showBottomSheet(
                      context,
                      featureName: 'Club Booking',
                      message: 'Sign in to book a table at ${widget.club.name}',
                      showContinueAsGuest: false,
                    );

                    if (!signedIn) {
                      return; // User dismissed dialog or didn't sign in
                    }

                    // Verify user actually signed in
                    final userAfter = ref.read(authStateProvider).value;
                    if (userAfter == null) {
                      return; // User didn't complete sign-in
                    }
                  }

                  // User is authenticated, proceed with booking
                  // Update state providers with the selected values
                  ref.read(selectedDateProvider.notifier).state = _selectedDate;

                  // Set time range based on selected time
                  if (_selectedTime != null) {
                    final startTime = _parseTimeString(_selectedTime!);
                    final endTime = startTime.add(const Duration(hours: 2)); // Default 2 hour duration
                    ref.read(timeRangeProvider.notifier).state = (startTime, endTime);
                  }

                  // Navigate to booking screen
                  if (mounted) {
                    context.push('/club-booking/${widget.club.id}');
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _selectedTime != null
                    ? AppColors.primaryGradient[0]
                    : Colors.grey,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proceed to book',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<String> _getTimeSlotsByMeal() {
    if (_selectedMeal == 'Lunch') {
      return _timeSlots.where((slot) => 
        slot.contains('12:') || 
        slot.contains('1:') || 
        slot.contains('2:')
      ).toList();
    } else {
      return _timeSlots.where((slot) => 
        slot.contains('7:') || 
        slot.contains('8:') || 
        slot.contains('9:')
      ).toList();
    }
  }
  
  Widget _buildSelectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
