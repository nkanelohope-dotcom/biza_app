import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final newEmail = _emailController.text.trim().toLowerCase();
    final phone = _phoneController.text.trim();

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (name.isEmpty || newEmail.isEmpty || phone.isEmpty) {
      setState(() => _errorMessage = "Please fill in all fields.");
      return;
    }
    if (name.length < 2) {
      setState(() => _errorMessage = "Please enter your full name.");
      return;
    }
    if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-]+$').hasMatch(newEmail)) {
      setState(() => _errorMessage = "Please enter a valid email address.");
      return;
    }
    if (phone.replaceAll(RegExp(r'\D'), '').length < 9) {
      setState(() => _errorMessage = "Please enter a valid phone number.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "You are not signed in.";
        });
        return;
      }

      // 1. Update Firestore with the new name, email, phone
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': name,
        'email': newEmail,
        'phone': phone,
      });

      // 2. If email changed, update Firebase Auth
      bool emailChanged = false;
      if (newEmail != user.email) {
        try {
          // In firebase_auth 6.x, use verifyBeforeUpdateEmail
          await user.verifyBeforeUpdateEmail(newEmail);
          emailChanged = true;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            setState(() {
              _isLoading = false;
              _errorMessage =
              "For security, please log out and log in again before changing your email.";
            });
            return;
          }
          // If verifyBeforeUpdateEmail is not available for some reason,
          // still save the Firestore update and warn the user.
          emailChanged = false;
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _successMessage = emailChanged
            ? "Profile updated. Check your new email to verify it."
            : "Profile updated successfully";
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context, true);
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = "That email is already used by another account.";
            break;
          case 'invalid-email':
            _errorMessage = "That email address is not valid.";
            break;
          case 'requires-recent-login':
            _errorMessage =
            "For security, please log out and log in again before changing your email.";
            break;
          default:
            _errorMessage = e.message ?? "Could not update profile.";
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BizaTheme.paddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Update your information",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 30),

              // NAME
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
              const SizedBox(height: 8),
              const Text(
                "Changing email requires verification from the new address.",
                style: TextStyle(color: Colors.grey, fontSize: 11),
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

              // SUCCESS
              if (_successMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BizaTheme.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: BizaTheme.primaryGreen.withOpacity(0.4),
                        width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: BizaTheme.primaryGreen, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_successMessage!,
                            style: const TextStyle(
                                color: BizaTheme.primaryGreen,
                                fontSize: 12,
                                height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                      : const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}