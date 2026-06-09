import 'package:flutter/material.dart';
import 'add_service_screen.dart';
import 'provider_dashboard_screen.dart';
import 'profile_screen.dart';
import 'provider_bookings_screen.dart'; // ✅ NEW
import '../services/api_service.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() =>
      _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {

  /// ✅ LOGOUT
  void logout() async {
    await ApiService.logout();

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login_provider",
      (route) => false,
    );
  }

  /// ✅ COMMON NAVIGATION
  void openScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// ✅ CARD UI
  Widget buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Provider Dashboard"),
        centerTitle: true,
        actions: [

          /// ✅ PROFILE
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              openScreen(const ProfileScreen());
            },
          ),

          /// ✅ LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Welcome 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Manage your services and grow your business",
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [

                  /// ✅ ADD SERVICE
                  buildActionCard(
                    "Add Service",
                    "Create a new service",
                    Icons.add_circle,
                    Colors.green,
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddServiceScreen(),
                        ),
                      );
                      setState(() {}); // refresh
                    },
                  ),

                  /// ✅ MY SERVICES
                  buildActionCard(
                    "My Services",
                    "Edit or delete your services",
                    Icons.dashboard,
                    Colors.blue,
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ProviderDashboardScreen(),
                        ),
                      );
                      setState(() {});
                    },
                  ),

                  /// ✅ BOOKINGS ✅ FIXED
                  buildActionCard(
                    "Bookings",
                    "View customer bookings",
                    Icons.calendar_month,
                    Colors.purple,
                    () {
                      openScreen(const ProviderBookingsScreen());
                    },
                  ),

                  /// ✅ CHAT ENTRY (NEW ✅)
                  buildActionCard(
                    "Chat with Customers",
                    "View and reply messages",
                    Icons.chat,
                    Colors.teal,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Open chat from bookings screen"),
                        ),
                      );
                    },
                  ),

                  /// ✅ ANALYTICS
                  buildActionCard(
                    "Analytics",
                    "Track your performance",
                    Icons.analytics,
                    Colors.orange,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Analytics coming soon"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      /// ✅ QUICK ADD BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddServiceScreen(),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}