import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../theme.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample bookings
  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 'BZA-2026-001',
      'service': 'Security Personnel',
      'guard': 'Thabo M.',
      'date': '23 September 2026',
      'time': '14:00',
      'location': 'Sandton, Johannesburg',
      'amount': 480.00,
      'status': 'Active',
      'rating': 0.0,
    },
    {
      'id': 'BZA-2026-002',
      'service': 'VIP Protection',
      'guard': 'Nomsa K.',
      'date': '20 September 2026',
      'time': '09:00',
      'location': 'Rosebank, Johannesburg',
      'amount': 1200.00,
      'status': 'Completed',
      'rating': 0.0,
    },
    {
      'id': 'BZA-2026-003',
      'service': 'Event Security',
      'guard': 'Sipho D.',
      'date': '15 September 2026',
      'time': '18:00',
      'location': 'Melrose Arch',
      'amount': 850.00,
      'status': 'Completed',
      'rating': 4.5,
    },
    {
      'id': 'BZA-2026-004',
      'service': 'Site Security',
      'guard': 'Lerato P.',
      'date': '10 September 2026',
      'time': '07:00',
      'location': 'Midrand',
      'amount': 320.00,
      'status': 'Cancelled',
      'rating': 0.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Filter bookings by tab
  List<Map<String, dynamic>> get _filteredBookings {
    final tab = _tabController.index;
    if (tab == 0) return _bookings;
    if (tab == 1) return _bookings.where((b) => b['status'] == 'Active').toList();
    if (tab == 2) return _bookings.where((b) => b['status'] == 'Completed').toList();
    return _bookings.where((b) => b['status'] == 'Cancelled').toList();
  }

  // Status colors
  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return BizaTheme.primaryGreen;
      case 'Completed':
        return Colors.blue;
      case 'Cancelled':
        return BizaTheme.accentRed;
      default:
        return Colors.grey;
    }
  }

  // ---------- CANCEL BOOKING ----------
  void _cancelBooking(int index) {
    final booking = _filteredBookings[index];
    final actualIndex = _bookings.indexOf(booking);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BizaTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cancel Booking",
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Text(
            "Are you sure you want to cancel your booking for ${booking['service']}?",
            style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keep Booking",
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: BizaTheme.accentRed),
            onPressed: () {
              setState(() {
                _bookings[actualIndex]['status'] = 'Cancelled';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Booking cancelled"),
                  backgroundColor: BizaTheme.accentRed,
                ),
              );
            },
            child:
            const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------- RATE BOOKING ----------
  void _rateBooking(int index) {
    final booking = _filteredBookings[index];
    final actualIndex = _bookings.indexOf(booking);
    double rating = booking['rating'] > 0 ? booking['rating'] : 0.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: BizaTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Rate Your Experience",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("How was your service with ${booking['guard']}?",
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 24),
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 44,
                    itemPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (value) {
                      setModalState(() => rating = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BizaTheme.primaryGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (rating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select a rating"),
                              backgroundColor: BizaTheme.accentRed,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _bookings[actualIndex]['rating'] = rating;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Thank you for your feedback!"),
                            backgroundColor: BizaTheme.primaryGreen,
                          ),
                        );
                      },
                      child: const Text("Submit Rating",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------- REBOOK ----------
  void _rebook(int index) {
    final booking = _filteredBookings[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BizaTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Rebook",
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Text(
            "Book ${booking['guard']} again for ${booking['service']}?",
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: BizaTheme.primaryGreen),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Opening booking flow..."),
                  backgroundColor: BizaTheme.primaryGreen,
                ),
              );
              // Later: Navigate to ChooseServiceScreen
            },
            child: const Text("Rebook",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ---------- BUILD BOOKING CARD ----------
  Widget _bookingCard(Map<String, dynamic> booking, int index) {
    final status = booking['status'] as String;
    final isActive = status == 'Active';
    final isCompleted = status == 'Completed';
    final isCancelled = status == 'Cancelled';
    final hasRating = (booking['rating'] as double) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: BizaTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? BizaTheme.primaryGreen.withOpacity(0.4)
              : Colors.grey.shade900,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: service + status badge
            Row(
              children: [
                Expanded(
                  child: Text(booking['service'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          color: _statusColor(status),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("ID: ${booking['id']}",
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 14),

            // Guard row
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['guard'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const Text("Security Officer",
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Date, time, location
            _infoRow(Icons.calendar_today, "${booking['date']}  •  ${booking['time']}"),
            const SizedBox(height: 6),
            _infoRow(Icons.location_on, booking['location']),

            const SizedBox(height: 14),

            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("R ${(booking['amount'] as double).toStringAsFixed(2)}",
                    style: const TextStyle(
                        color: BizaTheme.primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons based on status
            if (isActive) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelBooking(index),
                      icon: const Icon(Icons.cancel_outlined,
                          color: BizaTheme.accentRed, size: 18),
                      label: const Text("Cancel",
                          style: TextStyle(
                              color: BizaTheme.accentRed, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: BizaTheme.accentRed, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Tracking your guard..."),
                            backgroundColor: BizaTheme.primaryGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_on,
                          color: Colors.black, size: 18),
                      label: const Text("Track",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BizaTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (isCompleted) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rateBooking(index),
                      icon: Icon(
                        hasRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                      label: Text(
                        hasRating
                            ? "Rated ${booking['rating']}"
                            : "Rate",
                        style: const TextStyle(
                            color: Colors.amber, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Colors.amber, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rebook(index),
                      icon: const Icon(Icons.refresh,
                          color: Colors.black, size: 18),
                      label: const Text("Rebook",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BizaTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (isCancelled) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: BizaTheme.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text("This booking was cancelled",
                    style: TextStyle(
                        color: BizaTheme.accentRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }

  // Empty state widget
  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
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
        title: const Text("My Bookings",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: BizaTheme.primaryGreen,
          labelColor: BizaTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          labelStyle:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Active"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: _filteredBookings.isEmpty
          ? _emptyState("No ${_tabController.index == 0 ? '' : _tabController.index == 1 ? 'active ' : _tabController.index == 2 ? 'completed ' : 'cancelled '}bookings yet")
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredBookings.length,
        itemBuilder: (context, index) =>
            _bookingCard(_filteredBookings[index], index),
      ),
    );
  }
}