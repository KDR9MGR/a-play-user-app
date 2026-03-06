
import 'package:a_play/features/onboarding/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DateOfBirthScreen extends ConsumerStatefulWidget {
  final PageController pageController;
  const DateOfBirthScreen({super.key, required this.pageController});

  @override
  ConsumerState<DateOfBirthScreen> createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends ConsumerState<DateOfBirthScreen> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('When\'s your birthday?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: _selectedDate == null
                        ? 'Select your date of birth'
                        : DateFormat.yMMMd().format(_selectedDate!),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedDate != null) {
                  ref.read(onboardingControllerProvider.notifier).updateProfile(
                        ref.read(onboardingControllerProvider).copyWith(
                              dob: _selectedDate,
                            ),
                      );
                }
                widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
