import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await AuthService.logout();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen(role: 'customer')));
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}