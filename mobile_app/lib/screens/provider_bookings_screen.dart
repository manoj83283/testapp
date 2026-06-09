import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() =>
      _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState
    extends State<ProviderBookingsScreen> {

  List bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future loadBookings() async {
    try {
      final data = await ApiService.getProviderBookings();

      setState(() {
        bookings = data;
        loading = false;
      });

    } catch (e) {
      setState(() => loading = false);
    }
  }

  /// ✅ UPDATE STATUS + REFRESH UI
  Future updateStatus(String id, String status) async {
    await ApiService.updateBookingStatus(
      bookingId: id,
      status: status,
    );

    loadBookings(); // ✅ refresh instantly
  }

  /// ✅ STATUS COLOR
  Color getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "accepted":
        return Colors.blue;
      case "in_progress":
        return Colors.purple;
      case "completed":
        return Colors.green;
      case "rejected":
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// ✅ STATUS BUTTONS LOGIC
  Widget buildActions(Map b) {
    String status = b["status"];

    if (status == "pending") {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => updateStatus(b["_id"], "accepted"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Accept"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => updateStatus(b["_id"], "rejected"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Reject"),
            ),
          ),
        ],
      );
    }

    if (status == "accepted") {
      return ElevatedButton(
        onPressed: () => updateStatus(b["_id"], "in_progress"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        child: const Text("Start Work"),
      );
    }

    if (status == "in_progress") {
      return ElevatedButton(
        onPressed: () => updateStatus(b["_id"], "completed"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text("Mark Completed"),
      );
    }

    return Text(
      status.toUpperCase(),
      style: TextStyle(
        color: getStatusColor(status),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Bookings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadBookings,
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text("No bookings yet"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: bookings.length,
                  itemBuilder: (context, i) {
                    final b = bookings[i];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// ✅ SERVICE NAME
                            Text(
                              b["service"]?["name"] ?? "Service",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            /// ✅ CUSTOMER
                            Text("User: ${b["user"]?["email"] ?? ""}"),

                            /// ✅ ADDRESS
                            Text("Address: ${b["address"] ?? ""}"),

                            /// ✅ PRICE
                            Text("₹ ${b["totalPrice"] ?? 0}"),

                            const SizedBox(height: 5),

                            /// ✅ STATUS
                            Row(
                              children: [
                                const Text("Status: "),
                                Text(
                                  b["status"],
                                  style: TextStyle(
                                    color: getStatusColor(b["status"]),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// ✅ ACTION BUTTONS
                            buildActions(b),

                            const SizedBox(height: 10),

                            /// ✅ CHAT BUTTON
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.chat),
                                label: const Text("Chat"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        roomId: b["user"]["_id"],
                                        currentUserId:b["service"]["provider"],
                                        receiverId: b["user"]["_id"],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}