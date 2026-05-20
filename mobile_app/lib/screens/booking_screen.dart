import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'booking_success_screen.dart'; // ✅ Optional success screen (Step 4)

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  final TextEditingController notesCtrl = TextEditingController();
  bool isLoading = false;

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

  // 🔹 Step 2: Confirm Booking (API call)
  Future<void> _confirmBooking() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a booking date")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ApiService.createBooking(
        serviceId: widget.service["_id"],
        date: selectedDate!,
        notes: notesCtrl.text,
      );

      // ✅ Step 3: Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Booking successful")),
      );

      // ✅ Step 4: Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return Scaffold(
      appBar: AppBar(title: Text('Book ${s["name"] ?? "Service"}')),
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

            // 🔹 Service Info
            Text(
              s["description"] ?? "No description available",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
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
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedDate == null
                    ? "Select Date"
                    : "Date: ${selectedDate!.toLocal().toString().split(' ')[0]}",
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Confirm Booking Button
            ElevatedButton(
              onPressed: isLoading ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Confirm Booking"),
            ),
          ],
        ),
      ),
    );
  }
}