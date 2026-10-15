import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../theme.dart';
import 'tracking_screen.dart';

class GuardSelectionScreen extends StatefulWidget {
  const GuardSelectionScreen({super.key});

  @override
  State<GuardSelectionScreen> createState() => _GuardSelectionScreenState();
}

class _GuardSelectionScreenState extends State<GuardSelectionScreen> {
  String _selectedGuard = "Thabo M.";
  final double _hourlyRate = 120.0;
  final double _estimatedHours = 1.5;
  double get _estimatedHold => _hourlyRate * _estimatedHours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Available Security Personnel",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _guardCard("Thabo M.", 4.9, 124, "5 min away", true),
                _guardCard("Nomsa K.", 4.8, 98, "7 min away", true),
                _guardCard("Sipho D.", 4.8, 76, "8 min away", true),
                _guardCard("Lerato P.", 4.7, 62, "10 min away", false),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
              Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                              text: "R120",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: " / hour",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text("Estimated arrival: 5 min",
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BizaTheme.primaryGreen,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _showAuthorizeDialog,
                  child: const Text("Confirm Booking",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- AUTHORIZE PAYMENT DIALOG ----------
  void _showAuthorizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BizaTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline,
                color: BizaTheme.primaryGreen, size: 22),
            SizedBox(width: 10),
            Text("Authorize Payment",
                style: TextStyle(color: Colors.white, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "We'll place a temporary hold on your card. You'll only be charged for the actual time used.",
              style:
              TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _authRow("Estimated Hold",
                      "R ${_estimatedHold.toStringAsFixed(2)}"),
                  const SizedBox(height: 8),
                  _authRow(
                      "Rate", "R ${_hourlyRate.toStringAsFixed(2)} / hour"),
                  const SizedBox(height: 8),
                  _authRow("Card", "Visa **** 4242"),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "You will not be charged until the service ends.",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BizaTheme.primaryGreen,
              foregroundColor: Colors.black,
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              // Simulate authorization request
              _processAuthorization();
            },
            child: const Text("Authorize & Book",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _processAuthorization() {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: BizaTheme.primaryGreen),
      ),
    );

    // Simulate bank authorization (1.5s)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.pop(context); // close loading

      // Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "R ${_estimatedHold.toStringAsFixed(2)} held on Visa **** 4242"),
          backgroundColor: BizaTheme.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to tracking
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TrackingScreen()),
      );
    });
  }

  Widget _authRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _guardCard(String name, double rating, int reviews, String time,
      bool isOnline) {
    bool isSelected = (_selectedGuard == name);

    return GestureDetector(
      onTap: isOnline
          ? () => setState(() => _selectedGuard = name)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? BizaTheme.primaryGreen : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                  color: BizaTheme.primaryGreen.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 55,
                height: 55,
                color:
                isOnline ? Colors.grey.shade400 : Colors.grey.shade300,
                child:
                const Icon(Icons.person, size: 35, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isOnline ? Colors.black : Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, index) => Icon(Icons.star,
                            color: isOnline
                                ? Colors.amber
                                : Colors.grey.shade400,
                            size: 14),
                        itemCount: 5,
                        itemSize: 14,
                      ),
                      const SizedBox(width: 6),
                      Text("$rating ($reviews)",
                          style: TextStyle(
                              fontSize: 12,
                              color: isOnline
                                  ? Colors.black87
                                  : Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(time,
                      style: TextStyle(
                          color: isOnline
                              ? BizaTheme.primaryGreen
                              : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (isOnline)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                    color: isSelected
                        ? BizaTheme.primaryGreen
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected
                            ? BizaTheme.primaryGreen
                            : Colors.grey.shade400,
                        width: 2)),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              )
            else
              const Text("Offline",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}