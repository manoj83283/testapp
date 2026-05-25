import 'package:flutter/material.dart';
import 'booking_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final name = service["name"] ?? "Service";
    final providerName = service["providerName"] ?? "Provider";
    final serviceType = service["serviceType"] ?? "";
    final priceRange = service["priceRange"] ?? "Price not available";
    final location = service["location"] ?? "Location not available";
    final rating = service["rating"] ?? 0;
    final reviews = service["reviewCount"] ?? service["reviews"] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(name.toString()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ✅ COVER IMAGE (placeholder)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: const Icon(Icons.storefront, size: 80),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ✅ SERVICE NAME
                  Text(
                    name.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// ✅ PROVIDER NAME
                  Text(
                    "by $providerName",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ✅ RATING
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 5),
                      Text(rating.toString()),
                      const SizedBox(width: 5),
                      Text("($reviews reviews)"),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// ✅ SERVICE TYPE
                  Text(
                    "Service Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(serviceType),

                  const SizedBox(height: 14),

                  /// ✅ LOCATION
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 5),
                      Expanded(child: Text(location)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// ✅ PRICE
                  Row(
                    children: [
                      const Icon(Icons.currency_rupee),
                      const SizedBox(width: 5),
                      Text(
                        priceRange,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ✅ DESCRIPTION (optional)
                  if (service["description"] != null) ...[
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(service["description"]),
                  ],

                  const SizedBox(height: 40),

                  /// ✅ BOOK BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingScreen(service: service),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Book Now",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
