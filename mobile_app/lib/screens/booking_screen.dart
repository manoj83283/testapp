import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/api_service.dart';
import 'booking_success_screen.dart';

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

  final TextEditingController notesController = TextEditingController();
  final TextEditingController addressController = TextEditingController(); // ✅ NEW
  final TextEditingController locationController = TextEditingController(); // ✅ NEW

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    notesController.dispose();
    addressController.dispose(); // ✅
    locationController.dispose(); // ✅
    super.dispose();
  }

  /// ✅ DATE PICKER
  void pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// ✅ COD BOOKING
  Future<void> bookCOD() async {
    try {
      setState(() => isLoading = true);

      await ApiService.createBooking(
        serviceId: widget.service["_id"],
        date: selectedDate!,
        notes: notesController.text.trim(),
        paymentMethod: "COD",
        address: addressController.text.trim(),     // ✅ NEW
        location: locationController.text.trim(),   // ✅ NEW
      );

      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BookingSuccessScreen(),
        ),
      );

    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    }
  }

  /// ✅ START PAYMENT
  void startPayment() {
    final service = widget.service;

    int amount = 500;

    if (service["pricePerDay"] != null) {
      amount = service["pricePerDay"];
    }

    var options = {
      'key': 'rzp_test_123', // replace later
      'amount': amount * 100,
      'name': service["name"] ?? "Service",
      'description': service["serviceType"] ?? "",
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Payment error: $e");
    }
  }

  /// ✅ PAYMENT SUCCESS
  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await ApiService.createBooking(
        serviceId: widget.service["_id"],
        date: selectedDate!,
        notes: notesController.text.trim(),
        paymentMethod: "ONLINE",
        address: addressController.text.trim(),     // ✅
        location: locationController.text.trim(),   // ✅
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BookingSuccessScreen(),
        ),
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

  void handleExternalWallet(ExternalWalletResponse response) {}

  @override
  Widget build(BuildContext context) {

    final service = widget.service;

    return Scaffold(
      appBar: AppBar(title: const Text("Book Service")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ SERVICE INFO
            Text(
              service["name"] ?? "",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text("Provider: ${service["providerName"] ?? ""}"),

            const SizedBox(height: 20),

            /// ✅ DATE
            const Text("Select Date"),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? "No date selected"
                        : "${selectedDate!.toLocal()}".split(" ")[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: pickDate,
                  child: const Text("Choose"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ✅ ADDRESS
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Enter Delivery Address",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            /// ✅ LOCATION
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Enter Location (City/Area)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ PAYMENT METHOD
            const Text("Payment Method"),

            DropdownButton<String>(
              value: paymentMethod,
              isExpanded: true,
              items: ["COD", "ONLINE"].map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            /// ✅ NOTES
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: "Additional Notes",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            /// ✅ BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {

                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select date")),
                          );
                          return;
                        }

                        if (addressController.text.trim().isEmpty ||
                            locationController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Enter address & location")),
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