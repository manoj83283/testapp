import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../main.dart'; // ✅ IMPORTANT for localeNotifier
import 'provider_bookings_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState
    extends State<ProviderDashboardScreen> {

  bool isOnline = true;
  bool isLocationEnabled = true;
  bool isLoading = true;

  double todayEarnings = 0;
  double monthlyEarnings = 0;

  int pendingOrders = 0;
  int completedOrders = 0;

  List bookings = [];
  List services = [];

  @override
  void initState() {
    super.initState();

    SocketService.connect();
    loadAllData();

    SocketService.listenBooking((data) => loadAllData());
    SocketService.listenBookingUpdate((data) => loadAllData());
  }

  @override
  void dispose() {
    SocketService.removeListeners();
    super.dispose();
  }

  /// ✅ LANGUAGE CHANGE (SAVE + APPLY)
  Future<void> changeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);

    localeNotifier.value = Locale(code);
  }

  /// ✅ LOAD DATA
  Future<void> loadAllData() async {
    setState(() => isLoading = true);

    try {
      final bookingData = await ApiService.getProviderBookings();
      final serviceData = await ApiService.getMyServices();

      double today = 0;
      double month = 0;
      int pending = 0;
      int completed = 0;

      for (var b in bookingData) {
        final price = (b["totalPrice"] ?? 0).toDouble();

        if (b["status"] == "pending") pending++;
        if (b["status"] == "completed") completed++;

        today += price;
        month += price;
      }

      setState(() {
        bookings = bookingData;
        services = serviceData;

        todayEarnings = today;
        monthlyEarnings = month;

        pendingOrders = pending;
        completedOrders = completed;

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /// ✅ UPDATE STATUS
  void updateStatus(String id, String status) async {
    await ApiService.updateBookingStatus(
      bookingId: id,
      status: status,
    );
    loadAllData();
  }

  /// ✅ DELETE SERVICE
  void deleteService(String id) async {
    await ApiService.deleteService(id);
    loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      drawer: buildDrawer(),

      appBar: AppBar(
        title: const Text("Provider Dashboard"),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, "/addService")
              .then((_) => loadAllData());
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Service"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadAllData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  /// ✅ STATUS CONTROLS
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text("Availability"),
                          subtitle:
                              Text(isOnline ? "Online ✅" : "Offline ❌"),
                          value: isOnline,
                          onChanged: (v) =>
                              setState(() => isOnline = v),
                        ),
                        SwitchListTile(
                          title: const Text("Location Sharing"),
                          subtitle: Text(isLocationEnabled
                              ? "Enabled 📍"
                              : "Disabled ❌"),
                          value: isLocationEnabled,
                          onChanged: (v) =>
                              setState(() => isLocationEnabled = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ✅ STATS
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.4,
                    children: [
                      buildCard("Today Earnings", "₹$todayEarnings",
                          Colors.green),
                      buildCard("Monthly Earnings",
                          "₹$monthlyEarnings", Colors.blue),
                      buildCard("Pending Orders", "$pendingOrders",
                          Colors.orange),
                      buildCard("Completed", "$completedOrders",
                          Colors.purple),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ✅ BOOKINGS
                  const Text(
                    "Recent Orders",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...bookings.take(5).map((b) {
                    final service = b["service"] ?? {};

                    return Card(
                      child: ListTile(
                        title: Text(service["name"] ?? ""),
                        subtitle: Text("Status: ${b["status"]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (b["status"] == "pending")
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () =>
                                    updateStatus(b["_id"], "accepted"),
                              ),
                            if (b["status"] == "accepted")
                              IconButton(
                                icon: const Icon(Icons.play_arrow,
                                    color: Colors.orange),
                                onPressed: () =>
                                    updateStatus(b["_id"], "in_progress"),
                              ),
                            if (b["status"] == "in_progress")
                              IconButton(
                                icon: const Icon(Icons.done,
                                    color: Colors.blue),
                                onPressed: () =>
                                    updateStatus(b["_id"], "completed"),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  /// ✅ SERVICES
                  const Text(
                    "My Services",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...services.map((s) {
                    final active = s["isActive"] ?? true;

                    return Card(
                      child: ListTile(
                        title: Text(s["name"] ?? ""),
                        subtitle: Text(
                          "${s["category"] ?? ""} • ₹${s["price"] ?? 0}",
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: active,
                              onChanged: (val) async {
                                await ApiService.updateServiceStatus(
                                    s["_id"], val);
                                setState(() {
                                  s["isActive"] = val;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  deleteService(s["_id"]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  /// ✅ DRAWER WITH LANGUAGE SWITCH
  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        children: [

          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Center(
              child: Text(
                "Provider Panel",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          /// ✅ LANGUAGE SELECTOR (UPGRADED)
          ValueListenableBuilder<Locale>(
            valueListenable: localeNotifier,
            builder: (_, locale, __) {
              return ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Select Language"),
                trailing: DropdownButton<String>(
                  value: locale.languageCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text("English")),
                    DropdownMenuItem(value: 'hi', child: Text("Hindi")),
                    DropdownMenuItem(value: 'te', child: Text("Telugu")),
                    DropdownMenuItem(value: 'ta', child: Text("Tamil")),
                    DropdownMenuItem(value: 'kn', child: Text("Kannada")),
                    DropdownMenuItem(value: 'ml', child: Text("Malayalam")),
                    DropdownMenuItem(value: 'mr', child: Text("Marathi")),
                    DropdownMenuItem(value: 'bn', child: Text("Bengali")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      changeLanguage(value);
                    }
                  },
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.pushNamed(context, "/profile"),
          ),

          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text("My Orders"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProviderBookingsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              await ApiService.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login_user",
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  /// ✅ CARD
  Widget buildCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
