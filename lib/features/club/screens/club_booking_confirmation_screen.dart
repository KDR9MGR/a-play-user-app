
import 'package:flutter/material.dart';

class ClubBookingConfirmationScreen extends StatelessWidget {
  const ClubBookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text('Your table is booked!', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
