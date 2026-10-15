import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'chat_screen.dart';
import 'payment_screen.dart';

class ActiveServiceScreen extends StatefulWidget {
  const ActiveServiceScreen({super.key});

  @override
  State<ActiveServiceScreen> createState() => _ActiveServiceScreenState();
}

class _ActiveServiceScreenState extends State<ActiveServiceScreen> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  void _openChat() {
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

  void _endService() {
    _ticker?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("End Service",
            style: TextStyle(color: Colors.black, fontSize: 17)),
        content: Text(
          "End the service with Thabo M.? You've been protected for ${_formatDuration(_elapsed)}.",
          style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startTimer();
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: BizaTheme.accentRed),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => PaymentScreen(elapsed: _elapsed)),
              );
            },
            child: const Text("End Service",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Progress ring based on a 60-minute billing cycle
    final totalSeconds = 3600.0;
    final progress = (_elapsed.inSeconds % totalSeconds) / totalSeconds;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
          onPressed: () {
            _ticker?.cancel();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Service in Progress",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            const Spacer(),

            // ---------- CIRCULAR TIMER ----------
            SizedBox(
              height: 240,
              width: 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Grey progress ring background
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 6,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.grey.shade300),
                  ),
                  // Green progress ring (fills as time passes)
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        BizaTheme.primaryGreen),
                  ),
                  // Center: time + label
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDuration(_elapsed),
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Time Elapsed",
                          style: TextStyle(
                              color: BizaTheme.primaryGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ---------- GUARD INFO CARD ----------
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Guard info row
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person,
                                color: Colors.grey, size: 36),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Thabo M.",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black)),
                              SizedBox(height: 4),
                              Text("Security Officer",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              SizedBox(height: 2),
                              Text("BZA-017",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Message button (outlined)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openChat,
                        icon: const Icon(Icons.message,
                            color: Colors.black, size: 18),
                        label: const Text("Message",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.grey.shade300, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // End Service button (solid red)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BizaTheme.accentRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _endService,
                        child: const Text("End Service",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}