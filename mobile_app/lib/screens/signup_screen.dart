import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'provider_home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final String role;

  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstCtrl = TextEditingController();
  final TextEditingController lastCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> handleSignup() async {
    print("🟢 Sign‑Up button pressed");

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final data = {
      "firstName": firstCtrl.text.trim(),
      "lastName": lastCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "password": passCtrl.text.trim(),
      "role": widget.role, // ✅ FLAG SENT
    };

    try {
      final res = await ApiService.signup(data);

      /// ✅ FIX: GET USER FIRST
      final user = res["user"];

      if (user == null) {
        Fluttertoast.showToast(msg: "Invalid server response");
        setState(() => isLoading = false);
        return;
      }

      /// ✅ SAFE ROLE EXTRACTION
      final role =
          (user["role"] ?? "").toString().toLowerCase().trim();

      print("✅ Signup role: $role");

      Fluttertoast.showToast(msg: "✅ Signup successful");

      /// ✅ ROLE-BASED NAVIGATION
      if (role == "provider") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProviderHomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }

    } catch (e) {
      print("❌ Signup error: $e");

      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    firstCtrl.dispose();
    lastCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProvider = widget.role == "provider";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: Text(
          isProvider ? "Provider Sign Up" : "Customer Sign Up",
        ),
        centerTitle: true,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                ),
              ],
            ),

            child: Form(
              key: _formKey,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// ✅ ROLE HEADER
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isProvider
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isProvider ? Icons.store : Icons.person,
                          color: isProvider ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isProvider
                              ? "Register as Service Provider"
                              : "Register as Customer",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ✅ FIRST NAME
                  TextFormField(
                    controller: firstCtrl,
                    decoration: InputDecoration(
                      labelText: "First Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 15),

                  /// ✅ LAST NAME
                  TextFormField(
                    controller: lastCtrl,
                    decoration: InputDecoration(
                      labelText: "Last Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 15),

                  /// ✅ EMAIL
                  TextFormField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) =>
                        v != null && v.contains("@")
                            ? null
                            : "Enter valid email",
                  ),

                  const SizedBox(height: 15),

                  /// ✅ PHONE
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: "Phone",
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) =>
                        v != null && v.length >= 10
                            ? null
                            : "Enter valid phone",
                  ),

                  const SizedBox(height: 15),

                  /// ✅ PASSWORD
                  TextFormField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) =>
                        v != null && v.length >= 6
                            ? null
                            : "Min 6 characters",
                  ),

                  const SizedBox(height: 20),

                  /// ✅ SIGNUP BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleSignup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Sign Up"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ✅ LOGIN NAVIGATION
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LoginScreen(role: widget.role),
                        ),
                      );
                    },
                    child: Text(
                      isProvider
                          ? "Already a Provider? Login"
                          : "Already have an account? Login",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
