import 'package:flutter/material.dart';
import '../theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.security,
      'color': BizaTheme.primaryGreen,
      'title': 'Thabo M. is on the way',
      'body': 'Your security officer will arrive in 5 minutes.',
      'time': '2 min ago',
      'unread': true,
    },
    {
      'icon': Icons.check_circle,
      'color': Colors.blue,
      'title': 'Booking confirmed',
      'body': 'Your booking for Security Personnel on 23 Sep at 14:00 is confirmed.',
      'time': '1 hour ago',
      'unread': true,
    },
    {
      'icon': Icons.payment,
      'color': Colors.orange,
      'title': 'Payment successful',
      'body': 'R 480.00 has been charged to your Visa card ending in 4242.',
      'time': 'Yesterday',
      'unread': false,
    },
    {
      'icon': Icons.local_offer,
      'color': Colors.purple,
      'title': 'New promo: 20% off VIP Protection',
      'body': 'Use code VIP20 at checkout for your next booking.',
      'time': '2 days ago',
      'unread': false,
    },
    {
      'icon': Icons.star,
      'color': Colors.amber,
      'title': 'Rate your last service',
      'body': 'How was your experience with Nomsa K.?',
      'time': '3 days ago',
      'unread': false,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['unread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: BizaTheme.primaryGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BizaTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear all notifications?',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: const Text('This cannot be undone.',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: BizaTheme.accentRed),
            onPressed: () {
              setState(() => _notifications.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
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
        title: const Text('Notifications',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: BizaTheme.cardBackground,
              onSelected: (value) {
                if (value == 'read') _markAllAsRead();
                if (value == 'clear') _clearAll();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'read',
                  child: Text('Mark all as read',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear all',
                      style: TextStyle(color: BizaTheme.accentRed, fontSize: 13)),
                ),
              ],
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No notifications',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) =>
            Divider(color: Colors.grey.shade900, height: 1, indent: 76),
        itemBuilder: (context, i) {
          final n = _notifications[i];
          final unread = n['unread'] as bool;
          return InkWell(
            onTap: () {
              setState(() => _notifications[i]['unread'] = false);
            },
            child: Container(
              color: unread
                  ? BizaTheme.primaryGreen.withOpacity(0.05)
                  : Colors.transparent,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (n['color'] as Color).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(n['icon'] as IconData,
                        color: n['color'] as Color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n['title'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: unread
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (unread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: BizaTheme.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n['body'] as String,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          n['time'] as String,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}