import 'package:flutter/material.dart';
import 'provider_profile_edit_screen.dart';
import '../models/provider_model.dart';
import '../services/provider_service.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final String token;
  const ProviderDashboardScreen({required this.token, super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  ProviderModel? provider;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // You could fetch provider profile using token if you add a GET /providers/me endpoint.
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Dashboard')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : provider == null
              ? const Center(child: Text('Profile not loaded'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(provider!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(provider!.serviceType),
                      Text('Rating: ${provider!.rating}'),
                      Text('₹${provider!.pricePerHour}/hour | ₹${provider!.pricePerDay}/day'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProviderProfileEditScreen(token: widget.token)),
                        ),
                        child: const Text('Edit Profile / Upload Media'),
                      ),
                    ],
                  ),
                ),
    );
  }
}