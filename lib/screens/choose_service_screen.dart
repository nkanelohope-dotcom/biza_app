import 'package:flutter/material.dart';
import '../theme.dart';
import 'set_location_screen.dart';

class ChooseServiceScreen extends StatelessWidget {
  const ChooseServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color lightBg = Colors.white;
    const Color textDark = Color(0xFF1A1A1A);
    const Color textLightGrey = Color(0xFF757575);

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: BizaTheme.darkBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Choose a Service",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          _serviceItem(context, Icons.security, "Security Personnel", "On-demand guards", textDark, textLightGrey),
          _serviceItem(context, Icons.shield, "VIP Protection", "Executive & personal security", textDark, textLightGrey),
          _serviceItem(context, Icons.groups, "Event Security", "Events, functions, concerts", textDark, textLightGrey),
          _serviceItem(context, Icons.business, "Site Security", "Construction, business, residential", textDark, textLightGrey),
          _serviceItem(context, Icons.shopping_cart, "Retail Security", "Shops, malls, warehouses", textDark, textLightGrey),
          _serviceItem(context, Icons.person, "Specialised Security", "K9, armed, technical", textDark, textLightGrey),
        ],
      ),
    );
  }

  Widget _serviceItem(BuildContext context, IconData icon, String title, String subtitle, Color textColor, Color subtitleColor) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SetLocationScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: subtitleColor)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}