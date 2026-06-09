import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  double balance = 500; // ✅ Dummy balance (later from backend)

  final TextEditingController amountController =
      TextEditingController();

  /// ✅ ADD MONEY
  void addMoney() {
    final amount =
        double.tryParse(amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid amount")),
      );
      return;
    }

    setState(() {
      balance += amount;
    });

    amountController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Money added")),
    );
  }

  /// ✅ PAY FROM WALLET
  void payNow() {
    if (balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insufficient balance")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Payment Successful")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ WALLET BALANCE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Wallet Balance",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "₹$balance",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ ADD MONEY INPUT
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Enter Amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            /// ✅ ADD MONEY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addMoney,
                child: const Text("Add Money"),
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ PAY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),

                onPressed: payNow,
                child: const Text("Pay Using Wallet"),
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ TRANSACTION HISTORY (STATIC FOR NOW)
            const Text(
              "Recent Transactions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: const [

                  ListTile(
                    leading: Icon(Icons.arrow_downward,
                        color: Colors.green),
                    title: Text("Added ₹200"),
                    subtitle: Text("Success"),
                  ),

                  ListTile(
                    leading: Icon(Icons.arrow_upward,
                        color: Colors.red),
                    title: Text("Paid ₹150"),
                    subtitle: Text("Service Booking"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}