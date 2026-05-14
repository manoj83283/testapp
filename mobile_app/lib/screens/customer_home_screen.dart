import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:mobile_app/screens/booking_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});
  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<dynamic> services = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      services = await ApiService.fetchServices();
    } catch (e) {
      print(e);
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Home')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, i) {
                final s = services[i];
                return Card(
                  child: ListTile(
                    title: Text(s['name']),
                    subtitle: Text(s['description'] ?? ''),
                    trailing: Text('₹${s['pricePerHour'] ?? 0}/hr'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(service: s),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}