
import 'package:flutter/material.dart';

class ConciergeRequestConfirmationScreen extends StatelessWidget {
  const ConciergeRequestConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Received'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text('Your request has been received!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('A concierge will be in touch with you shortly.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
