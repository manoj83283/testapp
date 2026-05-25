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

  final TextEditingController notesController = TextEditingController();

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    notesController.dispose();
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

  /// ✅ START PAYMENT
  void startPayment() {
    final service = widget.service;

    int amount = 500; // default fallback ₹500

    try {
      if (service["priceRange"] != null) {
        // extract first number from "5000-20000"
        final priceText = service["priceRange"].toString();
        final firstValue =
            int.tryParse(priceText.split("-")[0].trim());

        if (firstValue != null) {
          amount = firstValue;
        }
      }
    } catch (_) {}

    var options = {
      'key': 'OIwHarT1IyC56LtTXcTvmu39', // ✅ replace this
      'amount': amount * 100, // paise
      'name': service["name"] ?? "Service",
      'description': service["serviceType"] ?? "",
      'prefill': {
        'contact': '9876543210',
        'email': 'test@test.com',
      }
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

  /// ✅ PAYMENT ERROR
  void handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Failed")),
    );
  }

  /// ✅ EXTERNAL WALLET
  void handleExternalWallet(ExternalWalletResponse response) {}

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book & Pay"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ SERVICE NAME
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

            /// ✅ DATE PICKER
            const Text(
              "Select Date",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

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
                  child: const Text("Choose Date"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ✅ NOTES
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: "Additional Notes",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const Spacer(),

            /// ✅ PAY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Select date first"),
                      ),
                    );
                    return;
                  }

                  startPayment();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Pay & Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
