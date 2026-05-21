import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NearbyServicesScreen extends StatefulWidget {
  final String categoryName;
  final String categoryKey;

  const NearbyServicesScreen({
    super.key,
    required this.categoryName,
    required this.categoryKey,
  });

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchQuery = "";
  late Future<List<dynamic>> servicesFuture;

  @override
  void initState() {
    super.initState();
    servicesFuture = ApiService.fetchServicesByCategory(widget.categoryKey);
  }

  void refreshServices() {
    setState(() {
      servicesFuture = ApiService.fetchServicesByCategory(widget.categoryKey);
    });
  }

  List<dynamic> filterServices(List<dynamic> services) {
    if (searchQuery.trim().isEmpty) {
      return services;
    }

    final query = searchQuery.toLowerCase().trim();

    return services.where((service) {
      final name = (service["name"] ?? "").toString().toLowerCase();
      final providerName =
          (service["providerName"] ?? "").toString().toLowerCase();
      final serviceType =
          (service["serviceType"] ?? "").toString().toLowerCase();
      final location = (service["location"] ?? "").toString().toLowerCase();
      final priceRange = (service["priceRange"] ?? "").toString().toLowerCase();

      return name.contains(query) ||
          providerName.contains(query) ||
          serviceType.contains(query) ||
          location.contains(query) ||
          priceRange.contains(query);
    }).toList();
  }

  void openChat(Map<String, dynamic> service) {
    final providerName = service["providerName"] ?? service["name"] ?? "Provider";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Chat with $providerName coming soon"),
      ),
    );
  }

  void bookService(Map<String, dynamic> service) {
    final serviceName = service["name"] ?? "service";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Booking $serviceName coming soon"),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: refreshServices,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nearby Services",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Available providers for ${widget.categoryName}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search providers or services",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                searchQuery = "";
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: servicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Error loading services:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  );
                }

                final allServices = snapshot.data ?? [];
                final visibleServices = filterServices(allServices);

                if (visibleServices.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        searchQuery.trim().isEmpty
                            ? "No service providers found for ${widget.categoryName}"
                            : "No matching providers found",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Row(
                        children: [
                          const Text(
                            "Service Providers",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${visibleServices.length} found",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: visibleServices.length,
                        itemBuilder: (context, index) {
                          final service = Map<String, dynamic>.from(
                            visibleServices[index] as Map,
                          );

                          return ServiceProviderCard(
                            service: service,
                            onChat: () => openChat(service),
                            onBook: () => bookService(service),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class ServiceProviderCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onChat;
  final VoidCallback onBook;

  const ServiceProviderCard({
    super.key,
    required this.service,
    required this.onChat,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final name = service["name"] ?? "Service";
    final providerName = service["providerName"] ?? "Provider";
    final serviceType = service["serviceType"] ?? "Event Service";
    final priceRange = service["priceRange"] ?? "Price on request";
    final location = service["location"] ?? "Location not available";
    final rating = service["rating"] ?? 0;
    final reviewCount = service["reviewCount"] ?? service["reviews"] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
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
                    name.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    providerName.toString(),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),

                  Text(
                    serviceType.toString(),
                    style: TextStyle(
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location.toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    priceRange.toString(),
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
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "($reviewCount reviews)",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onChat,
                          icon: const Icon(
                            Icons.chat_outlined,
                            size: 18,
                          ),
                          label: const Text("Chat"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onBook,
                          icon: const Icon(
                            Icons.calendar_month,
                            size: 18,
                          ),
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
  }
}