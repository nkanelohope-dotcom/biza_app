import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'active_service_screen.dart';
import 'chat_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  double _progress = 0.0;
  int _minutesAway = 5;
  Timer? _movementTimer;
  Timer? _countdownTimer;
  bool _isArriving = true;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTracking() {
    _movementTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.025;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _isArriving = false;
          timer.cancel();
          _countdownTimer?.cancel();
        }
      });
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        if (_minutesAway > 0) _minutesAway -= 1;
      });
    });
  }

  void _callGuard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BizaTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: BizaTheme.primaryGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call,
                  color: BizaTheme.primaryGreen, size: 34),
            ),
            const SizedBox(height: 20),
            const Text("Calling Thabo M. (BZA-017)",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Connecting...",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("End Call",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _messageGuard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(
          guardName: "Thabo M.",
          guardCode: "BZA-017",
        ),
      ),
    );
  }

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
          "Your Security is on the way",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // FAUX MAP AREA
          Container(
            color: const Color(0xFFE8EDE8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _GridPainter()),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RoutePainter(_progress),
                  ),
                ),
                Align(
                  alignment: Alignment(
                    -0.6 + (_progress * 1.2),
                    -0.5 + (_progress * 0.9),
                  ),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: BizaTheme.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 1),
                      ],
                    ),
                    child: const Icon(Icons.security,
                        color: Colors.black, size: 22),
                  ),
                ),
                const Align(
                  alignment: Alignment(0.5, 0.4),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              color: BizaTheme.primaryGreen, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _isArriving
                                ? "Arriving in $_minutesAway min"
                                : "Guard has arrived",
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM CARD
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 55,
                          height: 55,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.person,
                              size: 35, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Thabo M.",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                const Text("4.9 (124)",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text("Security Officer",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            const Text("BZA-017",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                          child: _outlineButton(
                              Icons.call, "Call", _callGuard)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _outlineButton(
                              Icons.message, "Message", _messageGuard)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BizaTheme.primaryGreen,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        _movementTimer?.cancel();
                        _countdownTimer?.cancel();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const ActiveServiceScreen()),
                        );
                      },
                        child: const Text("Guard Has Arrived",
                            style: TextStyle(fontWeight:
                            FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlineButton(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black, size: 18),
      label: Text(label,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 8;

    final thinPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 4;

    for (double y = 60; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 40; x < size.width; x += 90) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thinPaint);
    }
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  final double progress;
  _RoutePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * 0.2, size.height * 0.25);
    final end = Offset(size.width * 0.75, size.height * 0.65);

    final currentX = start.dx + (end.dx - start.dx) * progress;
    final currentY = start.dy + (end.dy - start.dy) * progress;
    final current = Offset(currentX, currentY);

    canvas.drawLine(current, end, paint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}