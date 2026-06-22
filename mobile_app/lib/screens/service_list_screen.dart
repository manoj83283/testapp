import 'dart:async'; // ✅ ADDED
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/socket_service.dart'; // ✅ ADDED
import 'service_detail_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {

  List services = [];
  bool isLoading = true;

  String sortBy = "smart";

  double? userLat;
  double? userLng;

  // ✅ TIMER
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getLocationAndFetch();

    // ✅ AUTO REFRESH EVERY 5 SECONDS
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchServices();
    });

    // ✅ ✅ REAL-TIME SOCKET LISTENER (YOUR REQUIREMENT)
    SocketService.socket.on("refreshServices", (data) {
      print("✅ Live refresh triggered");
      fetchServices(); // ✅ reload automatically
    });
  }

  // ============================================================
  // ✅ CLEANUP (IMPORTANT TO AVOID MEMORY LEAK)
  // ============================================================
  @override
  void dispose() {
    _timer?.cancel();

    // ✅ REMOVE SOCKET LISTENER (GOOD PRACTICE)
    SocketService.socket.off("refreshServices");

    super.dispose();
  }

  // ============================================================
  // ✅ GET USER LOCATION
  // ============================================================
  Future<void> getLocationAndFetch() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception("Location services disabled");
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLat = position.latitude;
      userLng = position.longitude;

      fetchServices();

    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location Error: $e")),
      );
    }
  }

  // ============================================================
  // ✅ FETCH SERVICES (WITH SORT + LOCATION)
  // ============================================================
  Future<void> fetchServices() async {
    try {
      if (userLat == null || userLng == null) return;

      setState(() => isLoading = true);

      final url =
          "${ApiConfig.serviceUrl}?lat=$userLat&lng=$userLng&sort=$sortBy";

      final res = await http.get(Uri.parse(url));

      final data = jsonDecode(res.body);

      setState(() {
        services = data;
        isLoading = false;
      });

    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading services: $e")),
      );
    }
  }

  // ============================================================
  // ✅ UI
  // ============================================================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Services"),
      ),

      body: Column(
        children: [

          /// ✅ SORT DROPDOWN
          Padding(
            padding: const EdgeInsets.all(10),

            child: DropdownButton<String>(
              value: sortBy,
              isExpanded: true,

              items: const [
                DropdownMenuItem(
                  value: "smart",
                  child: Text("Best Match"),
                ),
                DropdownMenuItem(
                  value: "nearest",
                  child: Text("Nearest"),
                ),
                DropdownMenuItem(
                  value: "low_price",
                  child: Text("Price Low to High"),
                ),
                DropdownMenuItem(
                  value: "high_price",
                  child: Text("Price High to Low"),
                ),
              ],

              onChanged: (val) {
                setState(() {
                  sortBy = val!;
                });

                fetchServices();
              },
            ),
          ),

          /// ✅ SERVICES LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())

                : services.isEmpty
                    ? const Center(child: Text("No Services Found"))

                    : ListView.builder(
                        itemCount: services.length,
                        itemBuilder: (context, index) {

                          final s = services[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.all(12),

                              title: Text(
                                s["name"] ?? "Service",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  const SizedBox(height: 5),

                                  /// ✅ PRICE
                                  Text("₹ ${s["pricePerDay"] ?? 0}"),

                                  /// ✅ DISTANCE
                                  if (s["distance"] != null)
                                    Text(
                                      "${(s["distance"] as num).toStringAsFixed(1)} km away",
                                    ),
                                ],
                              ),

                              trailing: const Icon(Icons.arrow_forward),

                              /// ✅ OPEN DETAIL SCREEN
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ServiceDetailScreen(service: s),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}