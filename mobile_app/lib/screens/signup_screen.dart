import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'customer_home_screen.dart';
import 'provider_home_screen.dart';

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String message = '';
  bool loading = false;

  Future<void> signup() async {
    setState(() => loading = true);
    final data = {
      'name': nameCtrl.text,
      'email': emailCtrl.text,
      'password': passCtrl.text,
      'role': widget.role,
    };
    final res = await ApiService.register(data);
    setState(() => loading = false);

    if (res['user'] != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.role == 'customer'
              ? const CustomerHomeScreen()
              : const ProviderHomeScreen(),
        ),
      );
    } else {
      setState(() => message = res['message'] ?? 'Signup failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.role} Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: nameCtrl, label: 'Name'),
            const SizedBox(height: 10),
            CustomTextField(controller: emailCtrl, label: 'Email'),
            const SizedBox(height: 10),
            CustomTextField(controller: passCtrl, label: 'Password', obscure: true),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : CustomButton(text: 'Signup', onPressed: signup),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(role: widget.role),
                ),
              ),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}