import 'package:flutter/material.dart';
import '../theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _simulateCall(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: BizaTheme.primaryGreen)),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!context.mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: BizaTheme.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(color: BizaTheme.primaryGreen.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.call, color: BizaTheme.primaryGreen, size: 34),
              ),
              const SizedBox(height: 20),
              const Text("Calling Support...", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Connecting you to the BIZA support line at 0800-BIZA-911.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: BizaTheme.primaryGreen),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BizaTheme.accentRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("End Call", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _simulateEmail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BizaTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.email_outlined, color: BizaTheme.primaryGreen, size: 24),
            SizedBox(width: 10),
            Text("Email Support", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Your email app would open with:\n\nTo: support@biza.co.za\nSubject: BIZA Support Request\n\nYou can describe your issue and our team will respond within 24 hours.",
          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BizaTheme.primaryGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
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
        title: const Text("Help & Support", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _faqItem("How do I book a guard?", "Select your location, choose a service, and confirm your booking. A guard will be dispatched immediately."),
          _faqItem("How do I cancel a booking?", "You can cancel a booking from the Bookings tab up to 15 minutes before the guard arrives."),
          _faqItem("What is the SOS button?", "The SOS button instantly alerts our emergency response team and sends your location to local authorities."),
          _faqItem("How do I contact support?", "You can call us at 0800-BIZA-911 or email support@biza.co.za."),
          _faqItem("How do payments work?", "All payments are processed securely through your saved card. You will be charged once the service is complete."),
          _faqItem("Is my information safe?", "Yes. All data is encrypted end-to-end. We never store your card details."),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _simulateCall(context),
              icon: const Icon(Icons.call, color: Colors.black),
              label: const Text("Call Support", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: BizaTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _simulateEmail(context),
              icon: const Icon(Icons.email_outlined, color: BizaTheme.primaryGreen),
              label: const Text("Email Support", style: TextStyle(color: BizaTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 15)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: BizaTheme.primaryGreen, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: BizaTheme.cardBackground, borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        iconColor: BizaTheme.primaryGreen,
        collapsedIconColor: Colors.grey,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}