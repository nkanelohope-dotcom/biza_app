import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'home_dashboard.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    HapticFeedback.lightImpact();
    final emailInput = _emailController.text.trim().toLowerCase();
    final passwordInput = _passwordController.text;

    setState(() => _errorMessage = null);

    if (emailInput.isEmpty || passwordInput.isEmpty) {
      setState(() => _errorMessage = "Please enter both email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailInput,
        password: passwordInput,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'user-not-found':
            _errorMessage =
            "No account found with that email. Please sign up first.";
            break;
          case 'wrong-password':
          case 'invalid-credential':
            _errorMessage = "Incorrect email or password.";
            break;
          case 'invalid-email':
            _errorMessage = "That email address is not valid.";
            break;
          case 'user-disabled':
            _errorMessage = "This account has been disabled.";
            break;
          case 'too-many-requests':
            _errorMessage =
            "Too many failed attempts. Please try again later.";
            break;
          default:
            _errorMessage = e.message ?? "Sign in failed. Please try again.";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Something went wrong. Please try again.";
      });
    }
  }

  Future<void> _showForgotPassword() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: BizaTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Reset Password",
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your email and we'll send you a reset link.",
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "you@example.com",
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BizaTheme.primaryGreen,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final email = controller.text.trim();
              Navigator.pop(dialogContext);
              if (email.isEmpty) return;
              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Reset link sent. Check your inbox."),
                    backgroundColor: BizaTheme.primaryGreen,
                  ),
                );
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? "Could not send reset link."),
                    backgroundColor: BizaTheme.accentRed,
                  ),
                );
              }
            },
            child: const Text("Send Link",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _comingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$provider sign-in will be enabled soon."),
        backgroundColor: BizaTheme.accentRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: BizaTheme.paddingH,
              vertical: BizaTheme.paddingV),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 130,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.security,
                    color: BizaTheme.primaryGreen,
                    size: 90,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text("Welcome Back",
                  style: BizaTheme.darkTheme.textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text("Sign in to continue"),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Email Address",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: BizaTheme.cardBackground,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: BizaTheme.cardBackground,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BizaTheme.accentRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: BizaTheme.accentRed.withOpacity(0.4),
                        width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: BizaTheme.accentRed, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                                color: BizaTheme.accentRed,
                                fontSize: 12,
                                height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPassword,
                  child: const Text("Forgot password?",
                      style: TextStyle(color: BizaTheme.primaryGreen)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                      : const Text("Sign In"),
                ),
              ),
              const SizedBox(height: 30),
              const Center(child: Text("Or continue with")),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _socialButton(Icons.g_mobiledata, "Google",
                            () => _comingSoon("Google")),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _socialButton(Icons.apple, "Apple",
                            () => _comingSoon("Apple")),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text("Sign Up",
                        style: TextStyle(
                            color: BizaTheme.primaryGreen,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(BizaTheme.buttonRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}