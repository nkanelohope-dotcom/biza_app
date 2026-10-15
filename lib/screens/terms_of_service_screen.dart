import 'package:flutter/material.dart';
import '../theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
        title: const Text("Terms of Service", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("BIZA Terms of Service", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Last updated: September 2026", style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 24),
            _SectionTitle("1. Acceptance of Terms"),
            _BodyText("By using the BIZA app you agree to these terms. If you do not agree, you may not use the service."),
            SizedBox(height: 16),
            _SectionTitle("2. Service Description"),
            _BodyText("BIZA is a platform that connects users with vetted security personnel on demand. We do not directly employ all guards."),
            SizedBox(height: 16),
            _SectionTitle("3. Payment Terms"),
            _BodyText("Payment is processed at the end of each booking. Rates are shown before confirmation."),
            SizedBox(height: 16),
            _SectionTitle("4. Cancellation Policy"),
            _BodyText("Free cancellation up to 15 minutes before the guard arrives. Late cancellations may incur a fee."),
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