import 'package:flutter/material.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(service["name"] ?? "Service")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(service["iconURL"], height: 100),
            const SizedBox(height: 10),
            Text(
              service["description"] ?? "No description available",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text("Rating: ⭐ ${service["avgRating"] ?? 0}"),
            Text("Providers: ${service["providerCount"] ?? 0}"),
            Text("Starting Price: ₹${service["basePrice"] ?? 0}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Booking flow coming soon")),
                );
              },
              child: const Text("Book Now"),
            ),
          ],
        ),
      ),
    );
  }
}