import 'package:flutter/material.dart';
import '../theme.dart';

class PaymentScreen extends StatefulWidget {
  final Duration elapsed;
  const PaymentScreen({super.key, required this.elapsed});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final List<Map<String, String>> _cards = [
    {
      'brand': 'Visa',
      'holder': 'Thabo Mokoena',
      'number': '**** 4242',
      'expiry': '12/26'
    },
    {
      'brand': 'Mastercard',
      'holder': 'Thabo Mokoena',
      'number': '**** 8888',
      'expiry': '08/25'
    },
  ];

  int _selectedIndex = 0;
  final double _hourlyRate = 120.0;
  final double _serviceFee = 15.0;

  // Real hours from the timer
  double get _hoursWorked => widget.elapsed.inSeconds / 3600.0;
  double get _subtotal => _hourlyRate * _hoursWorked;
  double get _total => _subtotal + _serviceFee;

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  void _processPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: BizaTheme.primaryGreen),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: BizaTheme.cardBackground,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  color: BizaTheme.primaryGreen, size: 70),
              const SizedBox(height: 16),
              const Text("Payment Successful",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("R ${_total.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: BizaTheme.primaryGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                "Charged to ${_cards[_selectedIndex]['brand']} ${_cards[_selectedIndex]['number']}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Time",
                            style: TextStyle(
                                color: Colors.grey, fontSize: 11)),
                        Text(_formatDuration(widget.elapsed),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Rate",
                            style: TextStyle(
                                color: Colors.grey, fontSize: 11)),
                        Text("R ${_hourlyRate.toStringAsFixed(2)} / hr",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
                  Navigator.pop(context);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Done",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    });
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
        title: const Text("Payment",
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BizaTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _summaryRow("Service", "Security Personnel"),
                  const SizedBox(height: 12),
                  _summaryRow("Guard", "Thabo M. (BZA-017)"),
                  const SizedBox(height: 12),
                  _summaryRow("Time Protected",
                      _formatDuration(widget.elapsed)),
                  const SizedBox(height: 12),
                  _summaryRow(
                      "Rate", "R ${_hourlyRate.toStringAsFixed(2)} / hour"),
                  const Divider(color: Colors.grey, height: 32),
                  _summaryRow(
                      "Subtotal", "R ${_subtotal.toStringAsFixed(2)}"),
                  const SizedBox(height: 8),
                  _summaryRow(
                      "Service Fee", "R ${_serviceFee.toStringAsFixed(2)}"),
                  const Divider(color: Colors.grey, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total to Charge",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text("R ${_total.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: BizaTheme.primaryGreen,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Select Payment Method",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(_cards.length, (index) {
              final card = _cards[index];
              final isSelected = index == _selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BizaTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                        color: BizaTheme.primaryGreen, width: 1.5)
                        : Border.all(
                        color: Colors.grey.shade800, width: 1),
                  ),
                  child: Row(
                    children: [
                      _brandBadge(card['brand']!),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(card['brand']!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                                "${card['number']}  •  Expires ${card['expiry']}",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? BizaTheme.primaryGreen
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? BizaTheme.primaryGreen
                                : Colors.grey.shade600,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                            size: 14, color: Colors.black)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _processPayment,
                icon: const Icon(Icons.lock, size: 18),
                label: const Text("Pay Now",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BizaTheme.primaryGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 12, color: Colors.grey),
                SizedBox(width: 6),
                Text("Payments are secured with 256-bit encryption",
                    style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _brandBadge(String brand) {
    final lower = brand.toLowerCase();
    if (lower.contains('visa')) {
      return Container(
        width: 50,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1434CB),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: const Text("VISA",
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic)),
      );
    }
    if (lower.contains('master')) {
      return Container(
        width: 50,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 10,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: Color(0xFFEB001B), shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: 10,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: Color(0xFFF79E1B), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: 50,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(6),
      ),
      child:
      const Icon(Icons.credit_card, color: Colors.white, size: 20),
    );
  }
}