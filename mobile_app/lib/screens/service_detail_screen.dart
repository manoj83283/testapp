import 'package:flutter/material.dart';
import '../screens/booking_screen.dart'; // ✅ Import the booking screen

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  DateTime? selectedDate;
  bool isLoading = false;
  final TextEditingController notesCtrl = TextEditingController();

  // 🔹 Step 1: Date Picker
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return Scaffold(
      appBar: AppBar(title: Text(s["name"] ?? "Service Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Service Image
            if (s["iconURL"] != null && s["iconURL"].isNotEmpty)
              Center(
                child: Image.network(
                  s["iconURL"],
                  height: 120,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.event, size: 100, color: Colors.blueAccent),
                ),
              ),
            const SizedBox(height: 20),

            // 🔹 Service Description
            Text(
              s["description"] ?? "No description available",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // 🔹 Service Info
            Text("⭐ Rating: ${s["avgRating"] ?? 0}"),
            Text("Providers: ${s["providerCount"] ?? 0}"),
            Text(
              "Starting Price: ₹${s["basePrice"] ?? 0}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 🔹 Notes Input
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: "Notes (optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // 🔹 Date Picker Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedDate == null
                          ? "Select Date"
                          : "Date: ${selectedDate!.toLocal().toString().split(' ')[0]}",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔹 Book Now Button
            ElevatedButton(
              onPressed: () {
                // ✅ Navigate to BookingScreen and pass full service data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(service: s),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Book Now"),
            ),
          ],
        ),
      ),
    );
  }
}