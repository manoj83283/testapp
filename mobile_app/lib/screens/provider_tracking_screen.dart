import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/socket_service.dart';

class ProviderTrackingScreen extends StatefulWidget {

  final String bookingId;

  const ProviderTrackingScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<ProviderTrackingScreen> createState() =>
      _ProviderTrackingScreenState();
}

class _ProviderTrackingScreenState
    extends State<ProviderTrackingScreen> {

  Timer? _locationTimer;

  double? currentLat;
  double? currentLng;

  bool isTracking = false;

  // ===================================================
  // ✅ START TRACKING
  // ===================================================
  void startTracking() {

    if (isTracking) return;

    /// ✅ ensure socket connected
    SocketService.connect();

    setState(() {
      isTracking = true;
    });

    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {

        try {
          Position pos =
              await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          setState(() {
            currentLat = pos.latitude;
            currentLng = pos.longitude;
          });

          /// ✅ ✅ FIXED (NAMED PARAMETERS)
          SocketService.updateLocation(
            roomId: widget.bookingId,
            lat: pos.latitude,
            lng: pos.longitude,
          );

          print("📍 Sent Location: ${pos.latitude}, ${pos.longitude}");

        } catch (e) {
          print("❌ Location error: $e");
        }
      },
    );
  }

  // ===================================================
  // ✅ STOP TRACKING
  // ===================================================
  void stopTracking() {

    _locationTimer?.cancel();

    setState(() {
      isTracking = false;
    });

    print("🛑 Tracking stopped");
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  // ===================================================
  // ✅ UI
  // ===================================================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Live Tracking"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ✅ STATUS ICON
            Icon(
              isTracking
                  ? Icons.gps_fixed
                  : Icons.gps_off,
              size: 80,
              color: isTracking ? Colors.green : Colors.grey,
            ),

            const SizedBox(height: 20),

            /// ✅ STATUS TEXT
            Text(
              isTracking
                  ? "Tracking is ON"
                  : "Tracking is OFF",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ LIVE COORDINATES
            if (currentLat != null && currentLng != null)
              Column(
                children: [
                  Text("Latitude: $currentLat"),
                  Text("Longitude: $currentLng"),
                ],
              )
            else
              const Text("Location not available"),

            const SizedBox(height: 40),

            /// ✅ START BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isTracking ? null : startTracking,
                icon: const Icon(Icons.play_arrow),
                label: const Text("Start Tracking"),
              ),
            ),

            const SizedBox(height: 10),

            /// ✅ STOP BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: isTracking ? stopTracking : null,
                icon: const Icon(Icons.stop),
                label: const Text("Stop Tracking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
