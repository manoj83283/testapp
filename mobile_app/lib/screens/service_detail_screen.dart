import 'package:flutter/material.dart';
import '../services/api_service.dart'; // ✅ IMPORTANT
import 'booking_screen.dart';
import 'chat_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final name = service["name"] ?? "Service";
    final providerName = service["providerName"] ?? "Provider";
    final serviceType = service["serviceType"] ?? "";
    final location = service["location"] ?? "Location not available";
    final rating = service["rating"] ?? 0;
    final reviews = service["reviewCount"] ?? 0;
    final pricePerDay = service["pricePerDay"] ?? 0;
    final imageUrl = service["imageUrl"] ?? "";
    final images = service["images"] ?? [];
    final providerId = service["provider"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(name.toString()),
      ),

      /// ✅ BODY
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ MAIN IMAGE
            imageUrl != ""
                ? Image.network(
                    imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.storefront, size: 80),
                  ),

            /// ✅ EXTRA IMAGES
            if (images is List && images.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          images[i],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ✅ NAME
                  Text(
                    name.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// ✅ PROVIDER
                  Text(
                    "by $providerName",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 12),

                  /// ✅ RATING
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text("$rating"),
                      const SizedBox(width: 5),
                      Text("($reviews reviews)"),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// ✅ PRICE BOX
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.currency_rupee),
                        Text(
                          "$pricePerDay / day",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// ✅ TYPE
                  if (serviceType.toString().isNotEmpty) ...[
                    const Text("Service Type",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(serviceType),
                    const SizedBox(height: 14),
                  ],

                  /// ✅ LOCATION
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 5),
                      Expanded(child: Text(location)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ✅ DESCRIPTION
                  if (service["description"] != null &&
                      service["description"].toString().isNotEmpty) ...[
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(service["description"]),
                    const SizedBox(height: 20),
                  ],

                  /// ✅ REVIEWS
                  const Text(
                    "Reviews",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (reviews == 0)
                    const Text("No reviews yet"),
                ],
              ),
            ),
          ],
        ),
      ),

      /// ✅ ✅ ✅ BOTTOM BAR (FIXED CHAT)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        child: Row(
          children: [
            /// ✅ CHAT BUTTON (🔥 FIXED)
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text("Chat"),
                onPressed: () async {
                  final userId = await ApiService.getUserId();

                  if (userId == null || providerId.toString().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User/Provider error")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        roomId: providerId,          // ✅ room
                        currentUserId: userId,       // ✅ customer
                        receiverId: providerId,      // ✅ provider
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            /// ✅ BOOK BUTTON
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text("Book Now"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BookingScreen(service: service),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}