import 'package:flutter/material.dart';
import '../theme.dart';

class ServiceHistoryScreen extends StatelessWidget {
  const ServiceHistoryScreen({super.key});

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
        title: const Text("Service History", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _historyItem("Security Personnel", "12 September 2026", "R 480.00", "Completed"),
          _historyItem("VIP Protection", "05 September 2026", "R 1,200.00", "Completed"),
          _historyItem("Event Security", "28 August 2026", "R 850.00", "Completed"),
          _historyItem("Site Security", "15 August 2026", "R 320.00", "Cancelled"),
        ],
      ),
    );
  }

  Widget _historyItem(String service, String date, String amount, String status) {
    bool isCompleted = status == "Completed";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: BizaTheme.cardBackground, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.security, color: isCompleted ? BizaTheme.primaryGreen : Colors.grey, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(status, style: TextStyle(color: isCompleted ? BizaTheme.primaryGreen : BizaTheme.accentRed, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}