import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'wallet_screen.dart';
import 'my_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.getProfile();

      setState(() {
        user = data["user"] ?? data["data"] ?? data;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> logout() async {
    await ApiService.logout();

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadProfile,
          ),
        ],
      ),
      body: buildContent(),
    );
  }

  Widget buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text("Error: $errorMessage"));
    }

    if (user == null) {
      return const Center(child: Text("No user data"));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        /// ✅ PROFILE HEADER (LIKE SWIGGY)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user!["firstName"] ?? ""} ${user!["lastName"] ?? ""}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(user!["email"] ?? ""),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: loadProfile,
              )
            ],
          ),
        ),

        const SizedBox(height: 20),

        /// ✅ QUICK ACTIONS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            quickAction(Icons.shopping_bag, "Orders", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyOrdersScreen(),
                ),
              );
            }),
            quickAction(Icons.account_balance_wallet, "Wallet", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WalletScreen(),
                ),
              );
            }),
            quickAction(Icons.star, "Ratings", () {}),
            quickAction(Icons.card_giftcard, "Rewards", () {}),
          ],
        ),

        const SizedBox(height: 25),

        /// ✅ ACCOUNT SECTION
        sectionCard([
          buildTile(
            icon: Icons.location_on,
            title: "My Address Book",
            onTap: () {},
          ),
          buildDivider(),
          buildTile(
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () {},
          ),
          buildDivider(),
          buildTile(
            icon: Icons.payment,
            title: "Payment Methods",
            onTap: () {},
          ),
        ]),

        const SizedBox(height: 20),

        /// ✅ SUPPORT SECTION
        sectionCard([
          buildTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {
              showSnack("Help coming soon");
            },
          ),
          buildDivider(),
          buildTile(
            icon: Icons.feedback,
            title: "Feedback",
            onTap: () {
              showSnack("Feedback coming soon");
            },
          ),
        ]),

        const SizedBox(height: 20),

        /// ✅ REFER
        buildOption(Icons.card_giftcard, "Refer & Earn", () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Refer & Earn"),
              content: const Text("Invite friends & earn rewards!"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            ),
          );
        }),

        const SizedBox(height: 10),

        /// ✅ SETTINGS
        buildOption(Icons.settings, "Settings", () {
          Navigator.pushNamed(context, "/settings");
        }),

        const SizedBox(height: 10),

        /// ✅ ABOUT
        buildOption(Icons.info, "About", () {
          showAboutDialog(
            context: context,
            applicationName: "Service App",
            applicationVersion: "1.0",
          );
        }),

        const SizedBox(height: 30),

        /// ✅ LOGOUT BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Logout"),
          ),
        ),
      ],
    );
  }

  /// ✅ QUICK ACTION BUTTON
  Widget quickAction(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// ✅ SECTION CARD
  Widget sectionCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  /// ✅ DIVIDER
  Widget buildDivider() {
    return const Divider(height: 1);
  }

  /// ✅ LIST TILE
  Widget buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// ✅ SIMPLE OPTION TILE
  Widget buildOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}