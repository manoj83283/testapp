import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../services/api_service.dart';
import 'booking_success_screen.dart';
import 'address_screen.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {

  DateTime? selectedDate;
  bool isLoading = false;

  String paymentMethod = "COD";

  final notesController = TextEditingController();
  final addressController = TextEditingController();
  final locationController = TextEditingController();

  Map<String, dynamic>? selectedAddress;

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    notesController.dispose();
    addressController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // ✅ DATE
  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ✅ SELECT SAVED ADDRESS
  Future<void> selectAddress() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressScreen()),
    );

    if (selected != null) {
      setState(() {
        selectedAddress = selected;

        addressController.text = selected["addressLine"] ?? "";
        locationController.text =
            "${selected["city"] ?? ""}, ${selected["state"] ?? ""}";
      });
    }
  }

  // ✅ AUTO LOCATION
  Future<void> detectLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(
              position.latitude, position.longitude);

      final place = placemarks.first;

      setState(() {
        addressController.text = place.street ?? "";
        locationController.text =
            "${place.locality ?? ""}, ${place.administrativeArea ?? ""}";
      });

    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  // ✅ FINAL ADDRESS
  String getFinalAddress() {
    if (selectedAddress != null) {
      return "${selectedAddress!["addressLine"]}, "
             "${selectedAddress!["city"]}, "
             "${selectedAddress!["state"]}";
    }
    return addressController.text.trim();
  }

  // ✅ COD BOOKING
  Future<void> bookCOD() async {
    try {
      setState(() => isLoading = true);

      await ApiService.createBooking(
        serviceId: widget.service["_id"],
        date: selectedDate!,
        notes: notesController.text.trim(),
        paymentMethod: "COD",
        address: getFinalAddress(),
        location: locationController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ✅ PAYMENT
  void startPayment() {
    int amount = widget.service["pricePerDay"] ?? 500;

    _razorpay.open({
      'key': 'rzp_test_123',
      'amount': amount * 100,
      'name': widget.service["name"] ?? "Service",
    });
  }

  // ✅ PAYMENT SUCCESS
  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await ApiService.createBooking(
        serviceId: widget.service["_id"],
        date: selectedDate!,
        notes: notesController.text.trim(),
        paymentMethod: "ONLINE",
        address: getFinalAddress(),
        location: locationController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    }
  }

  void handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Failed")),
    );
  }

  // ✅ UI
  @override
  Widget build(BuildContext context) {

    final service = widget.service;

    return Scaffold(
      appBar: AppBar(title: const Text("Book Service")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              service["name"] ?? "",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ DATE
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? "Select Date"
                        : selectedDate!.toString().split(" ")[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: pickDate,
                  child: const Text("Choose"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ✅ ADDRESS SELECT
            ElevatedButton.icon(
              onPressed: selectAddress,
              icon: const Icon(Icons.location_on),
              label: const Text("Select Saved Address"),
            ),

            const SizedBox(height: 10),

            /// ✅ ADDRESS + GPS
            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.blue),
                  onPressed: detectLocation,
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// ✅ LOCATION
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButton<String>(
              value: paymentMethod,
              isExpanded: true,
              items: ["COD", "ONLINE"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() => paymentMethod = val!);
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: "Notes",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {

                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Select date")),
                          );
                          return;
                        }

                        if (getFinalAddress().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Enter address")),
                          );
                          return;
                        }

                        if (paymentMethod == "COD") {
                          bookCOD();
                        } else {
                          startPayment();
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}