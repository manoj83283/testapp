import 'package:flutter/material.dart';

class BookingScreen extends StatelessWidget {
  final String service;
  const BookingScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book $service')),
      body: Center(child: Text('Booking page for $service')),
    );
  }
}