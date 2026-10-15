import 'package:flutter/material.dart';
import '../theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: const Text("Privacy Policy", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("BIZA Privacy Policy", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Last updated: September 2026", style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 24),
            _SectionTitle("1. Information We Collect"),
            _BodyText("We collect your name, email, phone number, and real-time location data in order to dispatch security personnel to your location."),
            SizedBox(height: 16),
            _SectionTitle("2. How We Use Your Data"),
            _BodyText("Your location is shared only with the assigned guard and our emergency response team during an active booking."),
            SizedBox(height: 16),
            _SectionTitle("3. Data Security"),
            _BodyText("All user data is encrypted in transit and at rest. We do not sell your personal information to third parties."),
            SizedBox(height: 16),
            _SectionTitle("4. Your Rights"),
            _BodyText("You may request a copy of your data or request deletion of your account at any time by contacting support@biza.co.za."),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: BizaTheme.primaryGreen, fontSize: 15, fontWeight: FontWeight.bold)),
  );
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.6));
}