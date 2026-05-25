import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState
    extends State<ProviderDashboardScreen> {
  bool isLoading = false;
  String? errorMessage;

  List<dynamic> services = [];

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.fetchServices();

      // ✅ IMPORTANT: Filter only provider services
      setState(() {
        services = data;
      });

    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void deleteService(int index) {
    setState(() {
      services.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Service removed (UI only)")),
    );

    // 🔥 Later connect DELETE API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadServices,
          )
        ],
      ),
      body: buildContent(),
    );
  }

  Widget buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text("Error: $errorMessage"),
      );
    }

    if (services.isEmpty) {
      return const Center(
        child: Text("No services added yet"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service =
            Map<String, dynamic>.from(services[index] as Map);

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ✅ SERVICE NAME
                Text(
                  service["name"] ?? "",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                /// ✅ CATEGORY
                Text("Category: ${service["category"] ?? ""}"),

                const SizedBox(height: 6),

                /// ✅ LOCATION
                Text("Location: ${service["location"] ?? ""}"),

                const SizedBox(height: 6),

                /// ✅ PRICE
                Text("Price: ${service["priceRange"] ?? ""}"),

                const SizedBox(height: 10),

                /// ✅ ACTION BUTTONS
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteService(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Edit coming soon"),
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}