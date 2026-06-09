import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'provider_bookings_screen.dart'; // ✅ NEW IMPORT

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState
    extends State<ProviderDashboardScreen> {

  List services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  /// ✅ LOAD PROVIDER SERVICES
  Future<void> loadServices() async {
    try {
      final data = await ApiService.getMyServices();

      setState(() {
        services = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  /// ✅ DELETE SERVICE
  void deleteService(String id) async {
    await ApiService.deleteService(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Service Deleted")),
    );

    loadServices();
  }

  /// ✅ REFRESH
  void refresh() {
    loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Dashboard"),
        actions: [

          /// ✅ BOOKINGS BUTTON (🔥 THIS FIXES "Coming Soon")
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProviderBookingsScreen(),
                ),
              );
            },
          ),

          /// ✅ REFRESH
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : services.isEmpty
              ? const Center(
                  child: Text("No services added yet"),
                )
              : ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {

                    final s = services[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: s["imageUrl"] != null &&
                                s["imageUrl"].toString().isNotEmpty
                            ? Image.network(
                                s["imageUrl"],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image),

                        title: Text(s["name"] ?? ""),

                        subtitle: Text(
                          "${s["category"]} • ₹${s["pricePerDay"] ?? 0}",
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            /// ✅ EDIT
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // 👉 You can navigate to edit screen later
                              },
                            ),

                            /// ✅ DELETE
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteService(s["_id"]);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

      /// ✅ ADD SERVICE BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pushNamed(context, "/add-service")
              .then((_) => loadServices());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}