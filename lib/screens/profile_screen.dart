import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'payment_methods_screen.dart';
import 'service_history_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _phone = '';
  String _photoPath = '';

  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      setState(() {
        _email = user.email ?? '';
        _name = doc.data()?['name'] ?? 'BIZA User';
        _phone = doc.data()?['phone'] ?? '';
        _photoPath = doc.data()?['photoPath'] ?? '';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _email = user.email ?? '';
        _name = 'BIZA User';
        _loading = false;
      });
    }
  }

  Future<void> _pickProfilePicture() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (picked == null) return;

      setState(() => _uploading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoPath': picked.path});

      if (!mounted) return;
      setState(() {
        _photoPath = picked.path;
        _uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile picture updated"),
          backgroundColor: BizaTheme.primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not update picture: $e"),
          backgroundColor: BizaTheme.accentRed,
        ),
      );
    }
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialName: _name,
          initialEmail: _email,
          initialPhone: _phone,
        ),
      ),
    );

    if (updated == true) {
      // Reload the data so the new name/email/phone appear
      setState(() => _loading = true);
      await _loadUserData();
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
          "My Profile",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: BizaTheme.primaryGreen),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // ---------- PROFILE PICTURE ----------
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: BizaTheme.primaryGreen,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: BizaTheme.cardBackground,
                    backgroundImage: _photoPath.isNotEmpty
                        ? FileImage(File(_photoPath))
                        : null,
                    child: _photoPath.isEmpty
                        ? Text(
                      _name.isNotEmpty
                          ? _name[0].toUpperCase()
                          : 'B',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                ),
                if (_uploading)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: BizaTheme.primaryGreen,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickProfilePicture,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: BizaTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ---------- NAME ----------
            Text(
              _name.isNotEmpty ? _name : 'BIZA User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // ---------- EDIT PROFILE BUTTON ----------
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openEditProfile,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: BizaTheme.primaryGreen,
                ),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: BizaTheme.primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: BizaTheme.primaryGreen,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ---------- MENU ITEMS ----------
            _profileOption(
              context,
              Icons.settings,
              "Settings",
              const SettingsScreen(),
            ),
            _profileOption(
              context,
              Icons.payment,
              "Payment Methods",
              const PaymentMethodsScreen(),
            ),
            _profileOption(
              context,
              Icons.history,
              "Service History",
              const ServiceHistoryScreen(),
            ),
            _profileOption(
              context,
              Icons.help_outline,
              "Help & Support",
              const HelpSupportScreen(),
            ),

            const SizedBox(height: 30),

            // ---------- LOG OUT ----------
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: BizaTheme.cardBackground,
                      title: const Text(
                        "Log Out",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        "Are you sure you want to log out?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BizaTheme.accentRed,
                          ),
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                                  (route) => false,
                            );
                          },
                          child: const Text(
                            "Log Out",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(
                  Icons.logout,
                  color: BizaTheme.accentRed,
                ),
                label: const Text(
                  "Log Out",
                  style: TextStyle(
                    color: BizaTheme.accentRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: BizaTheme.accentRed,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileOption(
      BuildContext context,
      IconData icon,
      String title,
      Widget destination,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: BizaTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: BizaTheme.primaryGreen),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        ),
      ),
    );
  }
}