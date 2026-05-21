import 'package:flutter/material.dart';

class NearbyServicesScreen extends StatelessWidget {
  final String categoryName;
  final String categoryKey;

  const NearbyServicesScreen({
    super.key,
    required this.categoryName,
    required this.categoryKey,
  });

  final List<Map<String, dynamic>> sampleProviders = const [
    {
      "name": "Royal Event Planners",
      "serviceType": "Decoration & Planning",
      "priceRange": "₹10,000 - ₹50,000",
      "rating": 4.6,
    },
    {
      "name": "Dream Photography",
      "serviceType": "Photography & Videography",
      "priceRange": "₹8,000 - ₹40,000",
      "rating": 4.8,
    },
    {
      "name": "Taste Makers Catering",
      "serviceType": "Catering Service",
      "priceRange": "₹250 - ₹800 / plate",
      "rating": 4.4,
    },
    {
      "name": "DJ Beats Events",
      "serviceType": "DJ & Music",
      "priceRange": "₹5,000 - ₹25,000",
      "rating": 4.5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nearby Services",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Available providers for $categoryName",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sampleProviders.length,
              itemBuilder: (context, index) {
                final provider = sampleProviders[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.12),
                          child: Icon(
                            Icons.storefront,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider["name"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                provider["serviceType"],
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                provider["priceRange"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(provider["rating"].toString()),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Chat with ${provider["name"]} coming soon",
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.chat),
                                      label: const Text("Chat"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Booking ${provider["name"]} coming soon",
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.calendar_month),
                                      label: const Text("Book"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}