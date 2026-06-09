import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {

  List bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  /// ✅ FETCH BOOKINGS
  Future<void> loadBookings() async {
    try {
      final data = await ApiService.getBookings();

      setState(() {
        bookings = data;
        isLoading = false;
      });

    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// ✅ OPEN CHAT
  void openChat(Map<String, dynamic> booking) {
    final service = booking["service"];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: service["provider"],
          currentUserId: service["provider"], // temp fix
          receiverId: service["provider"],
        ),
      ),
    );
  }

  /// ✅ STATUS COLOR SYSTEM 🔥
  Color getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "rejected":
      case "cancelled":
        return Colors.red;
      case "completed":
        return Colors.blue;
      case "in_progress":
        return Colors.purple;
      default:
        return Colors.orange; // pending
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : bookings.isEmpty
              ? const Center(child: Text("No Orders Yet"))

              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: bookings.length,
                  itemBuilder: (context, i) {

                    final b = bookings[i];
                    final service = b["service"] ?? {};

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
                              service["name"] ?? "Service",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            /// ✅ PROVIDER
                            Text(
                              "Provider: ${service["providerName"] ?? ""}",
                            ),

                            const SizedBox(height: 5),

                            /// ✅ DATE
                            Text(
                              "Date: ${b["date"]?.toString().split("T")[0] ?? ""}",
                            ),

                            const SizedBox(height: 8),

                            /// ✅ ✅ UPDATED STATUS UI 🔥
                            Row(
                              children: [

                                const Text("Status: "),
                                const SizedBox(width: 6),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(
                                      b["status"] ?? "pending",
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    (b["status"] ?? "pending")
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            /// ✅ ADDRESS
                            if (b["address"] != null)
                              Text("Address: ${b["address"]}"),

                            const SizedBox(height: 12),

                            /// ✅ ACTIONS
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,

                              children: [

                                /// ✅ CHAT
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.chat),
                                  label: const Text("Chat"),
                                  onPressed: () => openChat(b),
                                ),

                                /// ✅ CANCEL (ONLY IF ALLOWED)
                                if (b["status"] == "pending" ||
                                    b["status"] == "accepted")
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () async {

                                      await ApiService.cancelBooking(
                                        b["_id"],
                                      );

                                      loadBookings();
                                    },
                                    child: const Text("Cancel"),
                                  ),
                              ],
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