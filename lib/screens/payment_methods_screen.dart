import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, String>> _cards = [
    {
      'brand': 'Visa',
      'holder': 'Thabo Mokoena',
      'number': '**** 4242',
      'expiry': '12/26',
      'cvv': '***',
    },
    {
      'brand': 'Mastercard',
      'holder': 'Thabo Mokoena',
      'number': '**** 8888',
      'expiry': '08/25',
      'cvv': '***',
    },
  ];

  int _defaultIndex = 0;

  // ---------- DETECT BRAND ----------
  String? _detectBrand(String number) {
    final clean = number.replaceAll(" ", "");
    if (clean.isEmpty) return null;
    final first = clean[0];
    final firstTwo = clean.length >= 2 ? clean.substring(0, 2) : "";

    if (first == '4') return 'Visa';
    if (first == '5' ||
        firstTwo == '22' ||
        firstTwo == '23' ||
        firstTwo == '24' ||
        firstTwo == '25' ||
        firstTwo == '26' ||
        firstTwo == '27') return 'Mastercard';
    if (first == '3' || firstTwo == '34' || firstTwo == '37') return 'Amex';
    return null;
  }

  // ---------- LUHN'S ALGORITHM ----------
  bool _luhnCheck(String number) {
    final digits = number.split('').map(int.parse).toList();
    int sum = 0;
    bool alternate = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int n = digits[i];
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  // ---------- VALIDATE ALL CARD DETAILS ----------
  String? _validateCard({
    required String holder,
    required String number,
    required String expiry,
    required String cvv,
    required String? brand,
  }) {
    // 1. Card Holder
    if (holder.trim().isEmpty) {
      return "Card holder name is required.";
    }
    if (holder.trim().length < 3) {
      return "Card holder name is too short.";
    }

    // 2. Card Number (EXACTLY 16 DIGITS)
    final cleanNumber = number.replaceAll(" ", "");
    if (cleanNumber.length != 16) {
      return "Card number must be exactly 16 digits.";
    }
    if (!_luhnCheck(cleanNumber)) {
      return "Invalid card number. Please check and try again.";
    }

    // 3. Brand
    if (brand == null) {
      return "Unknown card brand. Only Visa, Mastercard and Amex are supported.";
    }

    // 4. Expiry (MM/YY)
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
      return "Expiry must be in MM/YY format.";
    }
    final parts = expiry.split('/');
    final month = int.parse(parts[0]);
    final year = 2000 + int.parse(parts[1]);
    if (month < 1 || month > 12) {
      return "Expiry month must be between 01 and 12.";
    }
    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1, 0);
    if (expiryDate.isBefore(now)) {
      return "This card has already expired.";
    }

    // 5. CVV
    if (brand == 'Amex') {
      if (cvv.length != 4) return "Amex CVV must be 4 digits.";
    } else {
      if (cvv.length != 3) return "CVV must be 3 digits.";
    }

    return null;
  }

  // ---------- SHOW INVALID ALERT ----------
  void _showInvalidAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BizaTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: BizaTheme.accentRed, size: 26),
            SizedBox(width: 10),
            Text("Invalid Card Details",
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: BizaTheme.accentRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ---------- ADD CARD ----------
  void _addCard() {
    String? detectedBrand;

    final holderController = TextEditingController();
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: BizaTheme.cardBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      const Text("Add New Card",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text(
                          "Enter your card details below. Your information is encrypted.",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 24),

                      // Detected brand preview
                      if (detectedBrand != null) ...[
                        Row(
                          children: [
                            BrandLogo(brand: detectedBrand!),
                            const SizedBox(width: 12),
                            Text("$detectedBrand detected",
                                style: const TextStyle(
                                    color: BizaTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ---------- HOLDER ----------
                      const Text("Card Holder Name",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: holderController,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "e.g. Thabo Mokoena",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.black,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ---------- CARD NUMBER ----------
                      const Text("Card Number",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: numberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16), // <-- MAX 16 DIGITS
                          _CardNumberFormatter(),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            detectedBrand = _detectBrand(value);
                          });
                        },
                        style: const TextStyle(
                            color: Colors.white, letterSpacing: 2, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "1234 5678 9012 3456",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          suffixIcon: detectedBrand != null
                              ? Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: BrandLogo(brand: detectedBrand!),
                          )
                              : null,
                          prefixIcon: const Icon(Icons.credit_card, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.black,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ---------- EXPIRY + CVV ----------
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Expiry Date",
                                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: expiryController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                    _ExpiryDateFormatter(),
                                  ],
                                  style: const TextStyle(
                                      color: Colors.white, letterSpacing: 2, fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: "MM/YY",
                                    hintStyle: TextStyle(color: Colors.grey.shade700),
                                    prefixIcon:
                                    const Icon(Icons.date_range, color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.black,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("CVV",
                                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: cvvController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  style: const TextStyle(
                                      color: Colors.white, letterSpacing: 4, fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: "123",
                                    hintStyle: TextStyle(color: Colors.grey.shade700),
                                    prefixIcon: const Icon(Icons.lock_outline,
                                        color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.black,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ---------- SAVE BUTTON ----------
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BizaTheme.primaryGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            final error = _validateCard(
                              holder: holderController.text,
                              number: numberController.text,
                              expiry: expiryController.text,
                              cvv: cvvController.text,
                              brand: detectedBrand,
                            );

                            if (error != null) {
                              _showInvalidAlert(error);
                              return;
                            }

                            final rawNumber =
                            numberController.text.replaceAll(" ", "");
                            final last4 =
                            rawNumber.substring(rawNumber.length - 4);

                            setState(() {
                              _cards.add({
                                'brand': detectedBrand!,
                                'holder': holderController.text.trim(),
                                'number': '**** $last4',
                                'expiry': expiryController.text,
                                'cvv': '***',
                              });
                            });

                            Navigator.pop(context);

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: BizaTheme.cardBackground,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: Row(
                                  children: const [
                                    Icon(Icons.check_circle,
                                        color: BizaTheme.primaryGreen, size: 26),
                                    SizedBox(width: 10),
                                    Text("Card Saved",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                content: Text(
                                    "Your $detectedBrand card ending in $last4 has been saved.",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK",
                                        style: TextStyle(
                                            color: BizaTheme.primaryGreen,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text("Save Card",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------- DELETE ----------
  void _deleteCard(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BizaTheme.cardBackground,
        title: const Text("Delete Card", style: TextStyle(color: Colors.white)),
        content: Text(
            "Are you sure you want to remove your ${_cards[index]['brand']} card?",
            style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: BizaTheme.accentRed),
            onPressed: () {
              setState(() {
                _cards.removeAt(index);
                if (_defaultIndex == index && _cards.isNotEmpty) {
                  _defaultIndex = 0;
                } else if (_cards.isEmpty) {
                  _defaultIndex = -1;
                } else if (_defaultIndex > index) {
                  _defaultIndex -= 1;
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------- SET DEFAULT ----------
  void _setDefault(int index) {
    setState(() => _defaultIndex = index);
  }

  // ---------- BUILD ----------
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
        title: const Text("Payment Methods",
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: _cards.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.credit_card_off, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No cards saved",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final isDefault = index == _defaultIndex;

                  return GestureDetector(
                    onTap: () => _setDefault(index),
                    onLongPress: () => _deleteCard(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: BizaTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: isDefault
                            ? Border.all(
                            color: BizaTheme.primaryGreen, width: 1.5)
                            : Border.all(
                            color: Colors.grey.shade800, width: 1),
                      ),
                      child: Row(
                        children: [
                          BrandLogo(brand: card['brand']!),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(card['brand']!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("Card Holder: ${card['holder']}",
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  "${card['number']}  •  Expires ${card['expiry']}",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: BizaTheme.accentRed, size: 22),
                            onPressed: () => _deleteCard(index),
                          ),
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: BizaTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text("Default",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10)),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addCard,
                icon: const Icon(Icons.add, color: BizaTheme.primaryGreen),
                label: const Text("Add New Card",
                    style: TextStyle(color: BizaTheme.primaryGreen)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: BizaTheme.primaryGreen, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap a card to set as default  •  Long press or tap trash to delete",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// INPUT FORMATTERS
// =========================================================

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(" ", "");
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonDigitIndex = i + 1;
      if (nonDigitIndex % 4 == 0 && nonDigitIndex != text.length) {
        buffer.write(" ");
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (text.length >= 3 && !text.contains("/")) {
      text = "${text.substring(0, 2)}/${text.substring(2)}";
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// =========================================================
// BRAND LOGO
// =========================================================
class BrandLogo extends StatelessWidget {
  final String brand;
  const BrandLogo({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final lower = brand.toLowerCase();

    if (lower.contains("visa")) {
      return Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1434CB),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 9,
              bottom: 9,
              child: CustomPaint(
                size: const Size(9, 9),
                painter: _VisaAccentPainter(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 6, bottom: 2),
              child: Text("VISA",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5)),
            ),
          ],
        ),
      );
    }

    if (lower.contains("master")) {
      return Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 13,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    color: Color(0xFFEB001B), shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: 13,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    color: Color(0xFFF79E1B), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      );
    }

    if (lower.contains("amex") || lower.contains("american")) {
      return Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF006FCF),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: const Text("AMEX",
            style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900)),
      );
    }

    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
    );
  }
}

class _VisaAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB600)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}