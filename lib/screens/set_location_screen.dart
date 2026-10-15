import 'package:flutter/material.dart';
import '../theme.dart';
import 'guard_selection_screen.dart';

class SetLocationScreen extends StatefulWidget {
  const SetLocationScreen({super.key});

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  String _locationName = "Sandton, Johannesburg";

  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _locations = [
    {'name': 'Sandton, Johannesburg', 'icon': Icons.location_city},
    {'name': 'Rosebank, Johannesburg', 'icon': Icons.location_city},
    {'name': 'Midrand, Gauteng', 'icon': Icons.location_city},
    {'name': 'Pretoria CBD', 'icon': Icons.location_city},
    {'name': 'Centurion, Pretoria', 'icon': Icons.location_city},
    {'name': 'Cape Town CBD', 'icon': Icons.location_city},
    {'name': 'Durban, KwaZulu-Natal', 'icon': Icons.location_city},
    {'name': 'Port Elizabeth, Eastern Cape', 'icon': Icons.location_city},
    {'name': 'Bloemfontein, Free State', 'icon': Icons.location_city},
    {'name': 'Stellenbosch, Western Cape', 'icon': Icons.location_city},
    {'name': '106 Madiba Street, Pretoria CBD', 'icon': Icons.home_outlined},
    {'name': '12 Nelson Mandela Square, Sandton', 'icon': Icons.home_outlined},
    {'name': '45 Vilakazi Street, Soweto', 'icon': Icons.home_outlined},
    {'name': '8 Long Street, Cape Town CBD', 'icon': Icons.home_outlined},
    {'name': '77 Florida Road, Durban', 'icon': Icons.home_outlined},
  ];

  List<Map<String, dynamic>> get _filteredSuggestions {
    if (_searchQuery.trim().isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return _locations
        .where((loc) => (loc['name'] as String).toLowerCase().contains(q))
        .take(5)
        .toList();
  }

  bool _looksLikeAddress(String query) {
    if (query.trim().length < 4) return false;
    final hasNumber = RegExp(r'\d').hasMatch(query);
    final keywords = [
      'street', 'st', 'road', 'rd', 'avenue', 'ave', 'drive', 'dr', 'lane'
    ];
    final lower = query.toLowerCase();
    return hasNumber || keywords.any((k) => lower.contains(k));
  }

  void _selectLocation(String name) {
    setState(() {
      _locationName = name;
      _searchQuery = "";
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  void _useCurrentLocation() {
    _selectLocation("Current Location (GPS)");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Using your GPS location"),
        backgroundColor: BizaTheme.primaryGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Set Your Location",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
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
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on,
                          color: BizaTheme.primaryGreen, size: 60),
                      SizedBox(height: 4),
                      Text("SANDTON",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.map_outlined,
                            color: BizaTheme.primaryGreen, size: 14),
                        SizedBox(width: 6),
                        Text("Map preview",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                      ],
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Current Location",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: BizaTheme.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Enter a specific address",
                      hintStyle:
                      TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.grey, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.grey, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: _filteredSuggestions.isEmpty
                          ? (_looksLikeAddress(_searchQuery)
                          ? ListTile(
                        leading: const Icon(Icons.add_location_alt,
                            color: BizaTheme.primaryGreen, size: 22),
                        title: Text(
                          "Use \"${_searchQuery.trim()}\"",
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text("Custom street address",
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        onTap: () =>
                            _selectLocation(_searchQuery.trim()),
                      )
                          : const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "No matching locations. Try a street name, suburb or city.",
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ))
                          : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _filteredSuggestions.length,
                        itemBuilder: (context, i) {
                          final loc = _filteredSuggestions[i];
                          final isAddress = (loc['name'] as String)
                              .contains(RegExp(r'\d'));
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              isAddress
                                  ? Icons.home_outlined
                                  : Icons.location_city,
                              color: Colors.grey,
                              size: 20,
                            ),
                            title: Text(loc['name'],
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            onTap: () =>
                                _selectLocation(loc['name'] as String),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const GuardSelectionScreen()),
                        );
                      },
                      child: const Text("Continue",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GPS FLOATING BUTTON
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: _useCurrentLocation,
              child: const Icon(Icons.my_location,
                  color: BizaTheme.primaryGreen, size: 20),
            ),
          ),
        ],
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