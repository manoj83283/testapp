import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});
  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  String message = '';

  Future<void> createService() async {
    final data = {
      "name": nameCtrl.text,
      "description": descCtrl.text,
      "pricePerHour": double.tryParse(priceCtrl.text) ?? 0,
    };
    final res = await ApiService.postService(data);
    setState(() => message = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Service Name')),
          const SizedBox(height: 10),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 10),
          TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price per hour')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: createService, child: const Text('Add Service')),
          const SizedBox(height: 20),
          Text(message),
        ]),
      ),
    );
  }
}