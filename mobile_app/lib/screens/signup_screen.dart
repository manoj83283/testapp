import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
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
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();

  bool isLoading = false;

  DateTime? selectedDOB;

  // ===========================================================
  // ✅ DATE PICKER
  // ===========================================================
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDOB = picked;
        dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // ===========================================================
  // ✅ AGE CHECK
  // ===========================================================
  bool is18Plus(DateTime dob) {
    final today = DateTime.now();

    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age >= 18;
  }

  // ===========================================================
  // ✅ SIGNUP FIX (UPDATED)
  // ===========================================================
  Future<void> handleSignup() async {

    if (!_formKey.currentState!.validate()) return;

    if (selectedDOB == null) {
      showError("Date of Birth is required");
      return;
    }

    if (!is18Plus(selectedDOB!)) {
      showError("Must be 18+");
      return;
    }

    setState(() => isLoading = true);

    try {

      final res = await ApiService.signup(
        firstName: firstCtrl.text,
        lastName: lastCtrl.text,
        email: emailCtrl.text,
        phone: phoneCtrl.text,
        password: passCtrl.text,
        role: widget.role,
        dob: selectedDOB!.toIso8601String(), // ✅ IMPORTANT
        location: locationCtrl.text,
      );

      final user = res["user"];

      if (user == null) {
        Fluttertoast.showToast(msg: "Invalid response");
        return;
      }

      Fluttertoast.showToast(msg: "✅ Signup successful");

      if (!context.mounted) return;

      /// ✅ REDIRECT TO LOGIN
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login_user',
        (route) => false,
      );

    } catch (e) {
      showError("Error: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ===========================================================
  void showError(String msg) {
    Fluttertoast.showToast(msg: msg);
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
                children: [

                  /// ✅ HEADER
                  Text(
                    isProvider
                        ? "Register as Service Provider"
                        : "Register as Customer",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  buildField("First Name", firstCtrl),
                  const SizedBox(height: 12),

                  buildField("Last Name", lastCtrl),
                  const SizedBox(height: 12),

                  buildField("Email", emailCtrl, isEmail: true),
                  const SizedBox(height: 12),

                  buildField("Phone", phoneCtrl, isPhone: true),
                  const SizedBox(height: 12),

                  buildField("Password", passCtrl, isPassword: true),
                  const SizedBox(height: 12),

                  /// ✅ LOCATION
                  buildField("Location", locationCtrl),
                  const SizedBox(height: 12),

                  /// ✅ DOB FIELD
                  TextFormField(
                    controller: dobCtrl,
                    readOnly: true,
                    onTap: pickDate,
                    decoration: const InputDecoration(
                      labelText: "Date of Birth",
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 20),

                  /// ✅ BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleSignup,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Sign Up"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ✅ LOGIN NAV
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
                    child: const Text("Already have an account? Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================
  Widget buildField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPhone
          ? TextInputType.phone
          : isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "Required";
        if (isEmail && !v.contains("@")) return "Invalid email";
        if (isPhone && v.length < 10) return "Invalid phone";
        if (isPassword && v.length < 6) return "Min 6 characters";
        return null;
      },
    );
  }
}