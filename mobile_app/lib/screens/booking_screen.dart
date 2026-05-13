import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  const BookingScreen({super.key, required this.service});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final hoursCtrl = TextEditingController();
  String message = '';

  Future<void> bookService() async {
    final data = {
      "serviceId": widget.service['_id'],
      "providerId": widget.service['providerId']['_id'],
      "customerId": "demoCustomerId", // replace with logged‑in user id
      "hoursBooked": int.parse(hoursCtrl.text),
      "totalPrice": (widget.service['pricePerHour'] ?? 0) * int.parse(hoursCtrl.text),
      "date": DateTime.now().toIso8601String(),
      "status": "pending"
    };
    final res = await ApiService.createBooking(data);
    setState(() => message = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.service['name']}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Price per hour: ₹${widget.service['pricePerHour']}'),
          const SizedBox(height: 10),
          TextField(
            controller: hoursCtrl,
            decoration: const InputDecoration(labelText: 'Hours to book'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: bookService, child: const Text('Book Now')),
          const SizedBox(height: 20),
          Text(message),
        ]),
      ),
    );
  }
}