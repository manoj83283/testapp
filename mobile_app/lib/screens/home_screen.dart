import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/service_card.dart';
import 'service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      final data = await ApiService.fetchServices();
      setState(() {
        services = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EventEase Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final s = services[index];
                return ServiceCard(
                  name: s["name"],
                  iconURL: s["iconURL"],
                  rating: (s["avgRating"] ?? 0).toDouble(),
                  providerCount: s["providerCount"] ?? 0,
                  basePrice: (s["basePrice"] ?? 0).toDouble(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceDetailScreen(service: s),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}