import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../config/api_config.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {

  List addresses = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  // ======================================================
  // ✅ GET ADDRESSES
  // ======================================================
  Future loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/address"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      setState(() {
        addresses = data;
      });

    } catch (e) {
      debugPrint("Load error: $e");
    }
  }

  // ======================================================
  // ✅ AUTO DETECT LOCATION
  // ======================================================
  Future<void> detectLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(
              position.latitude, position.longitude);

      final place = placemarks.first;

      final data = {
        "type": "home",
        "addressLine": place.street ?? "",
        "landmark": place.name ?? "",
        "city": place.locality ?? "",
        "state": place.administrativeArea ?? "",
        "pincode": place.postalCode ?? "",
      };

      await saveAddress(data);

    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  // ======================================================
  // ✅ ADD / UPDATE ADDRESS
  // ======================================================
  Future saveAddress(Map data, {String? id}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = id == null
          ? "${ApiConfig.baseUrl}/address"
          : "${ApiConfig.baseUrl}/address/$id";

      final res = id == null
          ? await http.post(
              Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
              body: jsonEncode(data),
            )
          : await http.put(
              Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
              body: jsonEncode(data),
            );

      final response = jsonDecode(res.body);

      setState(() {
        addresses = response;
      });

    } catch (e) {
      debugPrint("Save error: $e");
    }
  }

  // ======================================================
  // ✅ DELETE ADDRESS
  // ======================================================
  Future deleteAddress(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/address/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      setState(() {
        addresses = data;
      });

    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  // ======================================================
  // ✅ SET DEFAULT
  // ======================================================
  Future setDefault(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.patch(
        Uri.parse("${ApiConfig.baseUrl}/address/default/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      setState(() {
        addresses = data;
      });

    } catch (e) {
      debugPrint("Default error: $e");
    }
  }

  // ======================================================
  // ✅ ADD / EDIT DIALOG
  // ======================================================
  void showAddressDialog({Map? existing}) {

    final lineCtrl = TextEditingController(text: existing?["addressLine"]);
    final landmarkCtrl = TextEditingController(text: existing?["landmark"]);
    final cityCtrl = TextEditingController(text: existing?["city"]);
    final stateCtrl = TextEditingController(text: existing?["state"]);
    final pinCtrl = TextEditingController(text: existing?["pincode"]);

    String type = existing?["type"] ?? "home";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(existing == null ? "Add Address" : "Edit Address"),

          content: SingleChildScrollView(
            child: Column(
              children: [

                DropdownButtonFormField(
                  value: type,
                  items: const [
                    DropdownMenuItem(value: "home", child: Text("Home")),
                    DropdownMenuItem(value: "work", child: Text("Work")),
                    DropdownMenuItem(value: "corporate", child: Text("Corporate")),
                    DropdownMenuItem(value: "other", child: Text("Other")),
                  ],
                  onChanged: (val) {
                    type = val.toString();
                  },
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: lineCtrl,
                  decoration: const InputDecoration(labelText: "Address Line"),
                ),

                TextField(
                  controller: landmarkCtrl,
                  decoration: const InputDecoration(
                    labelText: "Landmark (Optional)",
                  ),
                ),

                TextField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(labelText: "City"),
                ),

                TextField(
                  controller: stateCtrl,
                  decoration: const InputDecoration(labelText: "State"),
                ),

                TextField(
                  controller: pinCtrl,
                  decoration: const InputDecoration(labelText: "Pincode"),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                final data = {
                  "type": type,
                  "addressLine": lineCtrl.text,
                  "landmark": landmarkCtrl.text,
                  "city": cityCtrl.text,
                  "state": stateCtrl.text,
                  "pincode": pinCtrl.text,
                };

                await saveAddress(data, id: existing?["_id"]);

                Navigator.pop(context);
              },
              child: Text(existing == null ? "Save" : "Update"),
            ),
          ],
        );
      },
    );
  }

  // ======================================================
  // ✅ UI
  // ======================================================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("My Address")),

      body: addresses.isEmpty
          ? const Center(child: Text("No addresses found"))
          : ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, i) {

                final addr = addresses[i];

                return Card(
                  margin: const EdgeInsets.all(8),

                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(addr["addressLine"] ?? ""),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${addr["city"]}, ${addr["state"]}"),

                        if (addr["landmark"] != null &&
                            addr["landmark"] != "")
                          Text("Landmark: ${addr["landmark"]}"),

                        if (addr["isDefault"] == true)
                          const Text(
                            "Default Address",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),

                    onTap: () {
                      Navigator.pop(context, addr); 
                    },

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        IconButton(
                          icon: const Icon(Icons.check_circle),
                          onPressed: () => setDefault(addr["_id"]),
                        ),

                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showAddressDialog(existing: addr),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteAddress(addr["_id"]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          FloatingActionButton(
            heroTag: "gps",
            onPressed: detectLocation,
            child: const Icon(Icons.my_location),
          ),

          const SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "add",
            onPressed: () => showAddressDialog(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}