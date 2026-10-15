import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'choose_service_screen.dart';
import 'bookings_screen.dart';
import 'emergency_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentIndex = 0;
  String _currentLocation = "Sandton, Johannesburg";

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

  List<Map<String, dynamic>> get _filteredLocations {
    if (_searchQuery.trim().isEmpty) return _locations;
    final q = _searchQuery.toLowerCase();
    return _locations
        .where((loc) => (loc['name'] as String).toLowerCase().contains(q))
        .toList();
  }

  bool _looksLikeAddress(String query) {
    if (query.trim().length < 4) return false;
    final hasNumber = RegExp(r'\d').hasMatch(query);
    final streetKeywords = [
      'street', 'st', 'road', 'rd', 'avenue', 'ave', 'drive', 'dr',
      'lane', 'ln', 'way', 'boulevard', 'blvd', 'crescent', 'close',
      'place', 'pl', 'square', 'sq', 'highway', 'hwy', 'park'
    ];
    final lower = query.toLowerCase();
    return hasNumber || streetKeywords.any((k) => lower.contains(k));
  }

  void _showLocationPicker() {
    _searchQuery = "";
    _searchController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BizaTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _filteredLocations;
            final showUseAddress =
                _searchQuery.isNotEmpty && _looksLikeAddress(_searchQuery);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.78,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const Text("Change Location",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text(
                        "Search a suburb, city, or enter a street address.",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      onChanged: (value) {
                        setSheetState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: "Street address, suburb, or city",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.grey, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.grey, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setSheetState(() => _searchQuery = "");
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.black,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_searchQuery.trim().isEmpty) ...[
                      const Text("Use current location",
                          style: TextStyle(
                              color: BizaTheme.primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() =>
                          _currentLocation = "Current Location (GPS)");
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Using your GPS location"),
                              backgroundColor: BizaTheme.primaryGreen,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: BizaTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                BizaTheme.primaryGreen.withOpacity(0.3),
                                width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.my_location,
                                  color: BizaTheme.primaryGreen, size: 20),
                              SizedBox(width: 12),
                              Text("Use my current location",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Expanded(
                      child: filtered.isEmpty && !showUseAddress
                          ? _emptySearchState(setSheetState)
                          : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (showUseAddress) ...[
                            const Text("Search results",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            _useAddressTile(setSheetState),
                            const SizedBox(height: 16),
                          ],
                          if (filtered.isNotEmpty) ...[
                            Text(
                                showUseAddress
                                    ? "Saved locations"
                                    : (_searchQuery.isEmpty
                                    ? "Saved locations"
                                    : "${filtered.length} result${filtered.length == 1 ? "" : "s"} found"),
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...filtered.map((loc) {
                              final isSelected =
                                  _currentLocation == loc['name'];
                              return _locationTile(loc, isSelected);
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _searchQuery = "";
      _searchController.clear();
    });
  }

  Widget _useAddressTile(StateSetter setSheetState) {
    return GestureDetector(
      onTap: () {
        final address = _searchQuery.trim();
        setState(() => _currentLocation = address);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Location set to $address"),
            backgroundColor: BizaTheme.primaryGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BizaTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: BizaTheme.primaryGreen.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_location_alt,
                color: BizaTheme.primaryGreen, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Use \"${_searchQuery.trim()}\"",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  const Text("Search this address on the map",
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: BizaTheme.primaryGreen, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _locationTile(Map<String, dynamic> loc, bool isSelected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? BizaTheme.primaryGreen.withOpacity(0.15)
              : Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(
          loc['icon'],
          color: isSelected ? BizaTheme.primaryGreen : Colors.grey,
          size: 20,
        ),
      ),
      title: Text(loc['name'],
          style: TextStyle(
              color: isSelected ? BizaTheme.primaryGreen : Colors.white,
              fontSize: 13,
              fontWeight:
              isSelected ? FontWeight.bold : FontWeight.w500)),
      trailing: isSelected
          ? const Icon(Icons.check, color: BizaTheme.primaryGreen, size: 18)
          : null,
      onTap: () {
        setState(() => _currentLocation = loc['name']);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Location set to ${loc['name']}"),
            backgroundColor: BizaTheme.primaryGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  Widget _emptySearchState(StateSetter setSheetState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text("No location found for \"$_searchQuery\"",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          const Text("Try a street address, suburb, or city",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              final address = _searchQuery.trim();
              setState(() => _currentLocation = address);
              Navigator.pop(context);
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: BizaTheme.primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: BizaTheme.primaryGreen.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_location_alt,
                      color: BizaTheme.primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Text("Use \"$_searchQuery\"",
                      style: const TextStyle(
                          color: BizaTheme.primaryGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'Signed in';

    return Drawer(
      backgroundColor: BizaTheme.cardBackground,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade900, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.security,
                          color: BizaTheme.primaryGreen,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text("BIZA",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Welcome back",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(userEmail,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _drawerItem(
                    context,
                    icon: Icons.home_outlined,
                    title: "Home",
                    onTap: () => Navigator.pop(context),
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.calendar_today_outlined,
                    title: "My Bookings",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BookingsScreen()));
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.person_outline,
                    title: "My Profile",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()));
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.credit_card_outlined,
                    title: "Payment Methods",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()));
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const NotificationsScreen()));
                    },
                  ),
                  const Divider(
                      color: Colors.grey,
                      height: 24,
                      indent: 20,
                      endIndent: 20),
                  _drawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()));
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()));
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.info_outline,
                    title: "About BIZA",
                    onTap: () {
                      Navigator.pop(context);
                      showAboutDialog(
                        context: context,
                        applicationName: "BIZA",
                        applicationVersion: "1.0.0",
                        applicationLegalese:
                        "© 2026 BIZA Security. All rights reserved.",
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            _drawerItem(
              context,
              icon: Icons.logout,
              title: "Log Out",
              color: BizaTheme.accentRed,
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: BizaTheme.cardBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text("Log Out",
                        style: TextStyle(color: Colors.white, fontSize: 17)),
                    content: const Text(
                        "Are you sure you want to log out of BIZA?",
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: BizaTheme.accentRed),
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                                (route) => false,
                          );
                        },
                        child: const Text("Log Out",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        Color? color,
      }) {
    return ListTile(
      leading: Icon(icon, color: color ?? BizaTheme.primaryGreen, size: 22),
      title: Text(title,
          style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.security,
                color: BizaTheme.primaryGreen,
                size: 26,
              ),
            ),
            const SizedBox(width: 8),
            const Text("BIZA",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()),
                  );
                },
                icon: const Icon(Icons.notifications_none,
                    color: Colors.white),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: BizaTheme.accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    color: const Color(0xFF1E1E1E),
                    child: CustomPaint(painter: _DarkGridPainter()),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.map_outlined,
                              color: BizaTheme.primaryGreen, size: 12),
                          SizedBox(width: 6),
                          Text("Map preview",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 20,
                    child: GestureDetector(
                      onTap: _showLocationPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on,
                                color: BizaTheme.primaryGreen, size: 16),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints:
                              const BoxConstraints(maxWidth: 200),
                              child: Text(
                                _currentLocation,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                      top: 60,
                      left: 40,
                      child: _MapGuardMarker(isOnline: true)),
                  const Positioned(
                      top: 60,
                      right: 40,
                      child: _MapGuardMarker(isOnline: true)),
                  const Positioned(
                      bottom: 40,
                      left: 40,
                      child: _MapGuardMarker(isOnline: true)),
                  Positioned(
                    bottom: 40,
                    right: 40,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: BizaTheme.primaryGreen, width: 1),
                          ),
                          child: const Text("5 min\naway",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        const SizedBox(height: 4),
                        const _MapGuardMarker(isOnline: true),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 140,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 5)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("What do you need today?",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _serviceCard(
                          context, Icons.security, "Security Personnel"),
                      _serviceCard(context, Icons.shield, "VIP Protection"),
                      _serviceCard(context, Icons.groups, "Event Security"),
                      _serviceCard(context, Icons.business, "Site Security"),
                    ],
                  ),
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
                              const ChooseServiceScreen()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Request Security Now",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: BizaTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        elevation: 0,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 1:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BookingsScreen()));
              break;
            case 2:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EmergencyScreen()));
              break;
            case 3:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MessagesScreen()));
              break;
            case 4:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()));
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Bookings"),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: BizaTheme.accentRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("SOS",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),
            label: "Emergency",
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.message), label: "Messages"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _serviceCard(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ChooseServiceScreen()));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class _MapGuardMarker extends StatelessWidget {
  final bool isOnline;
  const _MapGuardMarker({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isOnline ? BizaTheme.primaryGreen : Colors.grey,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 2),
        ],
      ),
      child: const Icon(Icons.security, color: Colors.black, size: 20),
    );
  }
}

class _DarkGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 8;
    final thinPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 4;
    final diagonalPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 6;

    for (double y = 60; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 40; x < size.width; x += 90) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thinPaint);
    }
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.3),
      diagonalPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}