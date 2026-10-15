import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  int _passwordScore(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]\\/;~`+=]').hasMatch(password)) {
      score++;
    }
    return score;
  }

  String _passwordStrengthLabel(int score) {
    switch (score) {
      case 5:
        return "Strong";
      case 4:
        return "Good";
      case 3:
        return "Fair";
      case 2:
        return "Weak";
      case 1:
        return "Very weak";
      default:
        return "";
    }
  }

  Color _passwordStrengthColor(int score) {
    if (score >= 5) return BizaTheme.primaryGreen;
    if (score == 4) return Colors.lightGreen;
    if (score == 3) return Colors.orange;
    return BizaTheme.accentRed;
  }

  Future<void> _handleSignUp() async {
    HapticFeedback.lightImpact();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() => _errorMessage = null);

    // Validation
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      setState(() => _errorMessage = "Please fill in all the fields.");
      return;
    }
    if (name.length < 2) {
      setState(() => _errorMessage = "Please enter your full name.");
      return;
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = "Please enter a valid email address.");
      return;
    }
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 9) {
      setState(() => _errorMessage = "Please enter a valid phone number.");
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = "Password must be at least 8 characters.");
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      setState(() => _errorMessage = "Password must contain an uppercase letter.");
      return;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      setState(() => _errorMessage = "Password must contain a lowercase letter.");
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      setState(() => _errorMessage = "Password must contain a number.");
      return;
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]\\/;~`+=]').hasMatch(password)) {
      setState(() => _errorMessage = "Password must contain a special character.");
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create Firebase Auth user
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Save profile to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'photoPath': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dc) => AlertDialog(
          backgroundColor: BizaTheme.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: BizaTheme.primaryGreen, size: 24),
              SizedBox(width: 10),
              Text("Account Created",
                  style: TextStyle(color: Colors.white, fontSize: 17)),
            ],
          ),
          content: Text(
            "Welcome, $name! You can now sign in with:\n\nEmail: $email",
            style: const TextStyle(
                color: Colors.grey, fontSize: 13, height: 1.5),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BizaTheme.primaryGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(dc);
                  Navigator.pop(context);
                },
                child: const Text("Back to Sign In",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage =
            "An account already exists with that email. Please sign in.";
            break;
          case 'invalid-email':
            _errorMessage = "That email address is not valid.";
            break;
          case 'weak-password':
            _errorMessage = "Password is too weak. Choose a stronger one.";
            break;
          default:
            _errorMessage = e.message ?? "Sign up failed. Please try again.";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Something went wrong. Please try again.";
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _passwordRule(String text, bool satisfied) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check_circle : Icons.radio_button_unchecked,
            color: satisfied ? BizaTheme.primaryGreen : Colors.grey,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  color: satisfied ? BizaTheme.primaryGreen : Colors.grey,
                  fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passwordValue = _passwordController.text;
    final score = _passwordScore(passwordValue);
    final showStrength = passwordValue.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: BizaTheme.paddingH, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create Account",
                  style: BizaTheme.darkTheme.textTheme.displayLarge
                      ?.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              const Text("Join BIZA to request security on demand.",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 30),

              // FULL NAME
              const Text("Full Name",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Your full name",
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: BizaTheme.cardBackground,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // EMAIL
              const Text("Email Address",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "you@example.com",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: BizaTheme.cardBackground,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // PHONE
              const Text("Phone Number",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "+27 XX XXX XXXX",
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: BizaTheme.cardBackground,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // PASSWORD
              const Text("Password",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "e.g. Biza@2026",
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
                      borderSide: BorderSide.none),
                ),
              ),

              // PASSWORD STRENGTH
              if (showStrength) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(5, (index) {
                          final filled = index < score;
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: EdgeInsets.only(right: index == 4 ? 0 : 4),
                              decoration: BoxDecoration(
                                color: filled
                                    ? _passwordStrengthColor(score)
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _passwordStrengthLabel(score),
                      style: TextStyle(
                        color: _passwordStrengthColor(score),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BizaTheme.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade900, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Password must contain:",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _passwordRule("At least 8 characters", passwordValue.length >= 8),
                      _passwordRule("One uppercase letter (A-Z)", RegExp(r'[A-Z]').hasMatch(passwordValue)),
                      _passwordRule("One lowercase letter (a-z)", RegExp(r'[a-z]').hasMatch(passwordValue)),
                      _passwordRule("One number (0-9)", RegExp(r'[0-9]').hasMatch(passwordValue)),
                      _passwordRule("One special character (!@#\$%...)", RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]\\/;~`+=]').hasMatch(passwordValue)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // CONFIRM PASSWORD
              const Text("Confirm Password",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Re-enter your password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  filled: true,
                  fillColor: BizaTheme.cardBackground,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),

              // ERROR
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
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

              const SizedBox(height: 30),

              // SIGN UP
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                      : const Text("Sign Up"),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Sign In",
                        style: TextStyle(
                            color: BizaTheme.primaryGreen,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}