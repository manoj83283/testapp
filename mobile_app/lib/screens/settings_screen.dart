import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final phoneController = TextEditingController();

  void updatePhone() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Phone number updated (mock)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Update Mobile Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updatePhone,
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}