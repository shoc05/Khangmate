// FILE: lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes.dart';
import '../../widgets/app_logo.dart';
import '../../constants.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameC = TextEditingController();
  final emailC = TextEditingController();
  final cidC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();

  bool hide = true;
  bool loading = false;
  bool acceptListing = false;

  final _authService = AuthService();

  @override
  void dispose() {
    fullNameC.dispose();
    emailC.dispose();
    cidC.dispose();
    passC.dispose();
    confirmC.dispose();
    super.dispose();
  }

  // ✅ Strong Email Validator
  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  // ✅ CID Validator
  String? _cidValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "CID is required";
    final cid = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cid.isEmpty || cid.length > 11) {
      return "CID must be 1–11 digits";
    }
    return null;
  }

  // ✅ Stronger Password Validator (recommended)
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return "Enter password";
    if (value.length < 6) return "Minimum 6 characters";
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return "Must contain uppercase letter";
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
      return "Must contain a number";
    }
    return null;
  }

  // ✅ Confirm Password Validator
  String? _confirmValidator(String? value) {
    if (value != passC.text) return "Passwords do not match";
    return null;
  }

  Future<void> _submit() async {
    if (loading) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (!acceptListing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please confirm your listing agreement.")),
      );
      return;
    }

    // ✅ Clean values
    final fullName = fullNameC.text.trim();
    final email = emailC.text.trim();
    final cid = cidC.text.trim().replaceAll(RegExp(r'[^0-9]'), '');

    // ✅ Ensure at least one primary identifier is provided
    if (email.isEmpty && cid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Provide either email or CID.")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      if (email.isNotEmpty) {
        await _authService.signUp(
          email: email,
          password: passC.text,
          fullName: fullName,
          cid: cid,
          phone: null,
          username: null,
        );
      } else {
        await _authService.signUpWithCid(
          cid: cid,
          password: passC.text,
          fullName: fullName,
          phone: null,
          username: null,
        );
      }

      if (!mounted) return;

      setState(() => loading = false);

      // ✅ Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              SizedBox(height: 12),
              Text("Signup Successful!", textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, Routes.home);
              },
              child: const Text("Continue"),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B0B0D) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          child: Column(
            children: [
              const AppLogo(size: 72),
              const SizedBox(height: 16),

              // ✅ FORM
              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B0B0D) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Create your account",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: fullNameC,
                        decoration: const InputDecoration(labelText: "Full name"),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? "Enter full name" : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: emailC,
                        decoration:
                            const InputDecoration(labelText: "Email (optional)"),
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: cidC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: "CID number (1–11 digits)"),
                        validator: _cidValidator,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: passC,
                        obscureText: hide,
                        decoration: InputDecoration(
                          labelText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                                hide ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => hide = !hide),
                          ),
                        ),
                        validator: _passwordValidator,
                        onChanged: (_) =>
                            confirmC.text.isNotEmpty ? setState(() {}) : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: confirmC,
                        obscureText: hide,
                        decoration:
                            const InputDecoration(labelText: "Confirm password"),
                        validator: _confirmValidator,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: acceptListing,
                            onChanged: (v) =>
                                setState(() => acceptListing = v ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              "I confirm that any property listings I upload to KhangMate are accurate and I am responsible for their content.",
                              style: TextStyle(fontSize: 13),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Create account"),
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "Additional verification may be required when submitting listings.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Already have an account? Sign in",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
