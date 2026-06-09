import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'service_detail_screen.dart';
import 'booking_screen.dart';
import 'chat_screen.dart';

class NearbyServicesScreen extends StatefulWidget {
  final String categoryName;
  final String categoryKey;

  const NearbyServicesScreen({
    super.key,
    required this.categoryName,
    required this.categoryKey,
  });

  @override
  State<NearbyServicesScreen> createState() =>
      _NearbyServicesScreenState();
}

class _NearbyServicesScreenState
    extends State<NearbyServicesScreen> {

  final TextEditingController searchController =
      TextEditingController();

  String searchQuery = "";
  List<dynamic> services = [];
  List<Map<String, dynamic>> cart = [];

  String? currentUserId; // ✅ important

  @override
  void initState() {
    super.initState();
    loadUser();
    loadServices();
  }

  /// ✅ LOAD USER ID
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString("userId");
    });
  }

  /// ✅ LOAD SERVICES
  Future<void> loadServices() async {
    try {
      final data =
          await ApiService.fetchServicesByCategory(widget.categoryKey);

      setState(() {
        services = data;
      });
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  /// ✅ REFRESH
  void refreshServices() {
    loadServices();
  }

  /// ✅ FILTER
  List<dynamic> filterServices(List<dynamic> list) {
    if (searchQuery.trim().isEmpty) return list;

    final query = searchQuery.toLowerCase().trim();

    return list.where((s) {
      return (s["name"] ?? "").toLowerCase().contains(query) ||
          (s["providerName"] ?? "")
              .toLowerCase()
              .contains(query) ||
          (s["location"] ?? "").toLowerCase().contains(query);
    }).toList();
  }

  /// ✅ ADD TO CART
  void addToCart(Map<String, dynamic> service) {
    setState(() => cart.add(service));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${service["name"]} added")),
    );
  }

  // ✅✅✅ FIXED CHAT FUNCTION (IMPORTANT)
  Future<void> openChat(Map<String, dynamic> service) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getString("userId");

      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      /// ✅ HANDLE BOTH OBJECT & STRING
      String providerId;

      if (service["provider"] is Map) {
        providerId = service["provider"]["_id"] ?? "";
      } else {
        providerId = service["provider"] ?? "";
      }

      if (providerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid provider data")),
        );
        return;
      }

      /// ✅ IMPORTANT: CONSISTENT ROOM ID (SORTED)
      final sortedIds = [userId, providerId]..sort();
      final roomId = "${sortedIds[0]}_${sortedIds[1]}";

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            roomId: roomId,
            currentUserId: userId,
            receiverId: providerId,
          ),
        ),
      );
    } catch (e) {
      print("Chat Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to open chat")),
      );
    }
  }

  /// ✅ DETAILS
  void openDetails(Map<String, dynamic> service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailScreen(service: service),
      ),
    );
  }

  /// ✅ BOOK
  void bookService(Map<String, dynamic> service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filterServices(services);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshServices,
          ),
        ],
      ),

      body: Column(
        children: [

          /// ✅ SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search services...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          /// ✅ LIST
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No services found"))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final service =
                          Map<String, dynamic>.from(filtered[i]);

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(

                          onTap: () => openDetails(service),

                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.store),
                          ),

                          title: Text(service["name"] ?? ""),

                          subtitle: Text(
                              "${service["providerName"] ?? ""}\n${service["location"] ?? ""}"),

                          isThreeLine: true,

                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "₹${service["pricePerDay"] ?? 0}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),

                              /// ✅ CHAT BUTTON
                              GestureDetector(
                                onTap: () => openChat(service),
                                child: const Icon(
                                  Icons.chat,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      /// ✅ CART BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Cart: ${cart.length}")),
          );
        },
        child: const Icon(Icons.shopping_bag),
      ),
    );
  }
}