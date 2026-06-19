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

  final ScrollController _scrollController = ScrollController(); // ✅ NEW

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
        bookings = data.reversed.toList(); // ✅ LATEST FIRST
        isLoading = false;
      });

      /// ✅ AUTO SCROLL TO TOP
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });

    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// ✅ OPEN CHAT
  Future<void> openChat(Map<String, dynamic> booking) async {
    final service = booking["service"] ?? {};
    final currentUserId = await ApiService.getUserId();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: booking["_id"],
          currentUserId: currentUserId ?? "",
          receiverId: service["provider"]?["_id"] ??
                      service["provider"] ??
                      "",
        ),
      ),
    );
  }

  /// ✅ STATUS COLOR
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
        return Colors.orange;
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
                  controller: _scrollController, // ✅ CONNECTED
                  padding: const EdgeInsets.all(10),
                  itemCount: bookings.length,

                  itemBuilder: (context, i) {

                    final b = bookings[i];
                    final service = b["service"] ?? {};
                    final status = b["status"] ?? "pending";

                    final isLatest = i == 0; // ✅ LATEST IDENTIFY

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),

                      margin: const EdgeInsets.only(bottom: 12),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),

                        color: isLatest
                            ? Colors.green.withOpacity(0.08)
                            : Colors.white,

                        border: Border.all(
                          color: isLatest
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: isLatest ? 2 : 1,
                        ),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// ✅ SERVICE NAME + BADGE
                            Row(
                              children: [

                                Expanded(
                                  child: Text(
                                    service["name"] ?? "Service",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                if (isLatest)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),

                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                    child: const Text(
                                      "Latest",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            /// ✅ PROVIDER
                            Text(
                              "Provider: ${service["provider"]?["firstName"] ?? service["providerName"] ?? ""}",
                            ),

                            const SizedBox(height: 5),

                            /// ✅ DATE
                            Text(
                              "Date: ${b["date"]?.toString().split("T")[0] ?? ""}",
                            ),

                            const SizedBox(height: 8),

                            /// ✅ STATUS BADGE
                            Row(
                              children: [
                                const Text("Status: "),
                                const SizedBox(width: 6),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),

                                  decoration: BoxDecoration(
                                    color: getStatusColor(status),
                                    borderRadius: BorderRadius.circular(6),
                                  ),

                                  child: Text(
                                    status.toUpperCase(),
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

                            /// ✅ PRICE
                            if (b["totalPrice"] != null)
                              Text("₹ ${b["totalPrice"]}"),

                            const SizedBox(height: 12),

                            /// ✅ ACTION BUTTONS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                /// ✅ CHAT
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.chat),
                                  label: const Text("Chat"),
                                  onPressed: () => openChat(b),
                                ),

                                /// ✅ CANCEL
                                if (status == "pending" ||
                                    status == "accepted")
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),

                                    onPressed: () async {
                                      await ApiService.cancelBooking(b["_id"]);
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