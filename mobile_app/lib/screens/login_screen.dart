import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'customer_home_screen.dart';
import 'provider_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String message = '';
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    final res = await ApiService.login(emailCtrl.text, passCtrl.text);
    setState(() => loading = false);

    if (res['token'] != null) {
      await AuthService.saveToken(res['token']);
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
      setState(() => message = res['message'] ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.role} Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: emailCtrl, label: 'Email'),
            const SizedBox(height: 10),
            CustomTextField(controller: passCtrl, label: 'Password', obscure: true),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : CustomButton(text: 'Login', onPressed: login),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SignupScreen(role: widget.role),
                ),
              ),
              child: const Text('Don’t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupScreen extends StatelessWidget {
  final String role;
  const SignupScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Navigate to signup screen for $role')),
    );
  }
}