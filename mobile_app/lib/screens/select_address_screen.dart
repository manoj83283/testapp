import 'package:flutter/material.dart';

class SelectAddressScreen extends StatelessWidget {
  final List addresses;

  const SelectAddressScreen({super.key, required this.addresses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Address")),

      body: ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (_, i) {

          final addr = addresses[i];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.location_on),

              title: Text(addr["addressLine"]),

              subtitle: Text("${addr["city"]}, ${addr["state"]}"),

              onTap: () {
                Navigator.pop(context, addr); // return selected
              },
            ),
          );
        },
      ),
    );
  }
}