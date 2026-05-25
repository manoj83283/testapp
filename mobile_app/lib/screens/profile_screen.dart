import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
        /// ✅ PROFILE ICON
        const CircleAvatar(
          radius: 50,
          child: Icon(Icons.person, size: 50),
        ),

        const SizedBox(height: 20),

        /// ✅ NAME
        buildTile("First Name", user!["firstName"]),
        buildTile("Last Name", user!["lastName"]),

        /// ✅ EMAIL
        buildTile("Email", user!["email"]),

        /// ✅ PHONE
        buildTile("Phone", user!["phone"]),

        /// ✅ ROLE
        buildTile("Role", user!["role"] ?? "user"),

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

  Widget buildTile(String title, dynamic value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value?.toString() ?? ""),
      ),
    );
  }
}
