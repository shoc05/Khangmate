import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes.dart';
import '../../widgets/app_logo.dart';
import '../../constants.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  bool hide = true;
  bool loading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  Widget _socialButton({
    required String label,
    required IconData icon,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // subtle diagonal gradient background
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.black, const Color(0xFF0F1720)]
                  : [const Color(0xFFFDF7F8), const Color(0xFFFFF7F7)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const AppLogo(size: 84),
                const SizedBox(height: 18),
                // Card with rounded corners and shadow
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B0B0D) : AppColors.bgLavender,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Welcome to KhangMate',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailC,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email or CID (1-11 digits)'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passC,
                        obscureText: hide,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => hide = !hide),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loading ? null : () async {
                            final emailOrCid = emailC.text.trim();
                            final pass = passC.text;
                            if (emailOrCid.isEmpty || pass.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please enter both email/CID and password.')),
                              );
                              return;
                            }
                            
                            setState(() => loading = true);
                            
                            try {
                              await _authService.signIn(
                                emailOrCid: emailOrCid,
                                password: pass,
                              );
                              
                              if (mounted) {
                                setState(() => loading = false);
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => SuccessDialog(
                                    message: 'Login Successful!',
                                    onComplete: () {
                                      Navigator.pop(context); // close dialog
                                      Navigator.pushReplacementNamed(context, Routes.home);
                                    },
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => loading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Login failed: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Sign In',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                          child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, Routes.signup),
                        child: const Text('Create an account',
                            style:
                                TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // small legal text
                const Text('By continuing you agree to our Terms & Privacy',
                    style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example SuccessDialog widget if you don't have one
class SuccessDialog extends StatelessWidget {
  final String message;
  final VoidCallback onComplete;

  const SuccessDialog({super.key, required this.message, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 64),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
      ]),
      actions: [
        TextButton(
          onPressed: onComplete,
          child: const Text('Continue'),
        )
      ],
    );
  }
}
