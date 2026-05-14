import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String name;
  final String iconURL;
  final double rating;
  final int providerCount;
  final double basePrice;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.name,
    required this.iconURL,
    required this.rating,
    required this.providerCount,
    required this.basePrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(iconURL, height: 60, width: 60),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("⭐ $rating | $providerCount providers"),
              Text("Starts ₹$basePrice"),
            ],
          ),
        ),
      ),
    );
  }
}