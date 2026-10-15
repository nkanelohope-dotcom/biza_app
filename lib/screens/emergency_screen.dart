import 'package:flutter/material.dart';
import '../theme.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  // Stages: countdown -> sending -> dispatched
  String _stage = "countdown";
  int _countdown = 3;
  int _step = 0;

  // Steps shown during the "sending" stage
  final List<Map<String, String>> _steps = [
    {'icon': 'location', 'text': 'Locating your position...'},
    {'icon': 'police', 'text': 'Alerting local authorities (SAPS)...'},
    {'icon': 'contacts', 'text': 'Notifying your emergency contacts...'},
    {'icon': 'guard', 'text': 'Dispatching nearest BIZA guard...'},
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  // ---------- COUNTDOWN ----------
  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() => _countdown -= 1);
        _startCountdown();
      } else {
        setState(() => _stage = "sending");
        _startSendingSteps();
      }
    });
  }

  // ---------- STEP SEQUENCE ----------
  void _startSendingSteps() {
    if (_step < _steps.length) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _step += 1);
        _startSendingSteps();
      });
    } else {
      setState(() => _stage = "dispatched");
    }
  }

  // ---------- CANCEL ----------
  void _cancelEmergency() {
    Navigator.pop(context);
  }

  // ---------- ICON HELPER ----------
  IconData _iconFor(String name) {
    switch (name) {
      case 'location':
        return Icons.location_on;
      case 'police':
        return Icons.local_police;
      case 'contacts':
        return Icons.contacts;
      case 'guard':
        return Icons.security;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BizaTheme.accentRed,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // ----- CLOSE BUTTON -----
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: _cancelEmergency,
                ),
              ),
              const Spacer(),

              // ============================================================
              // STAGE 1: COUNTDOWN
              // ============================================================
              if (_stage == "countdown") ...[
                const Icon(Icons.emergency, size: 100, color: Colors.white),
                const SizedBox(height: 30),
                const Text("EMERGENCY",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                const SizedBox(height: 20),
                const Text("Sending alert in",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$_countdown",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Tap CANCEL if this was a mistake",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cancelEmergency,
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text("CANCEL EMERGENCY",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],

              // ============================================================
              // STAGE 2: SENDING
              // ============================================================
              if (_stage == "sending") ...[
                const Icon(Icons.wifi_tethering,
                    size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text("SENDING ALERT",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 30),
                // Steps list
                ...List.generate(_steps.length, (i) {
                  final step = _steps[i];
                  final isDone = i < _step;
                  final isActive = i == _step;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        // Icon circle
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.white
                                : Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: isDone
                              ? Icon(_iconFor(step['icon']!),
                              color: BizaTheme.accentRed, size: 22)
                              : isActive
                              ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Icon(_iconFor(step['icon']!),
                              color: Colors.white54, size: 22),
                        ),
                        const SizedBox(width: 16),
                        // Text
                        Expanded(
                          child: Text(
                            step['text']!,
                            style: TextStyle(
                                color: isDone || isActive
                                    ? Colors.white
                                    : Colors.white54,
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                        ),
                        // Checkmark
                        if (isDone)
                          const Icon(Icons.check_circle,
                              color: Colors.white, size: 22),
                      ],
                    ),
                  );
                }),
              ],

              // ============================================================
              // STAGE 3: DISPATCHED
              // ============================================================
              if (_stage == "dispatched") ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check,
                      color: BizaTheme.accentRed, size: 70),
                ),
                const SizedBox(height: 30),
                const Text("HELP IS ON THE WAY",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                const SizedBox(height: 20),
                const Text(
                  "Your location has been shared with authorities and your emergency contacts. A BIZA guard is being dispatched to your location.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 30),
                // ETA card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text("ESTIMATED ARRIVAL",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      const Text("5 - 8 minutes",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text("Nearest guard dispatched",
                          style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // ----- BOTTOM BUTTON -----
              if (_stage == "dispatched")
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: BizaTheme.accentRed,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text("I'M SAFE - CLOSE ALERT",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}