import 'package:flutter/material.dart';
import '../theme.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Sample conversations
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Thabo M.',
      'code': 'BZA-017',
      'lastMessage': 'I will be there in 5 minutes.',
      'time': '14:04',
      'unread': 2,
      'pinned': false,
    },
    {
      'name': 'Nomsa K.',
      'code': 'BZA-022',
      'lastMessage': 'Your service is confirmed for tomorrow at 09:00.',
      'time': 'Yesterday',
      'unread': 0,
      'pinned': false,
    },
    {
      'name': 'Sipho D.',
      'code': 'BZA-031',
      'lastMessage': 'Thank you for choosing BIZA.',
      'time': 'Mon',
      'unread': 0,
      'pinned': false,
    },
    {
      'name': 'Lerato P.',
      'code': 'BZA-044',
      'lastMessage': 'Service completed successfully.',
      'time': 'Last week',
      'unread': 0,
      'pinned': false,
    },
  ];

  // Sort: pinned first, then by original order
  List<Map<String, dynamic>> get _sortedChats {
    final sorted = [..._chats];
    sorted.sort((a, b) {
      if (a['pinned'] == b['pinned']) return 0;
      return a['pinned'] ? -1 : 1;
    });
    return sorted;
  }

  // ---------- PIN / UNPIN ----------
  void _togglePin(int index) {
    setState(() {
      _chats[index]['pinned'] = !_chats[index]['pinned'];
    });

    final isPinned = _chats[index]['pinned'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPinned
            ? "${_chats[index]['name']} pinned"
            : "${_chats[index]['name']} unpinned"),
        backgroundColor: BizaTheme.primaryGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ---------- DELETE ----------
  void _deleteChat(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BizaTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Conversation",
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Text(
            "Delete the conversation with ${_chats[index]['name']}? This cannot be undone.",
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: BizaTheme.accentRed),
            onPressed: () {
              final name = _chats[index]['name'];
              setState(() => _chats.removeAt(index));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Conversation with $name deleted"),
                  backgroundColor: BizaTheme.accentRed,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------- OPEN CHAT ----------
  void _openChat(int index) {
    final chat = _chats[index];
    // Clear unread when opened
    setState(() => _chats[index]['unread'] = 0);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          guardName: chat['name'],
          guardCode: chat['code'],
        ),
      ),
    );
  }

  // ---------- LONG PRESS MENU ----------
  void _showOptions(int index) {
    final chat = _chats[index];
    final isPinned = chat['pinned'] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: BizaTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: BizaTheme.primaryGreen),
              title: Text(isPinned ? "Unpin conversation" : "Pin conversation",
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _togglePin(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: BizaTheme.accentRed),
              title: const Text("Delete conversation",
                  style: TextStyle(color: BizaTheme.accentRed, fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _deleteChat(index);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ---------- TIME COLOR HIGHLIGHT ----------
  Color _timeColor(Map<String, dynamic> chat) {
    if (chat['unread'] > 0) return BizaTheme.primaryGreen;
    if (chat['pinned'] == true) return BizaTheme.primaryGreen;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final chats = _sortedChats;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Messages",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          if (_chats.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: BizaTheme.cardBackground,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.done_all,
                              color: BizaTheme.primaryGreen),
                          title: const Text("Mark all as read",
                              style: TextStyle(color: Colors.white, fontSize: 14)),
                          onTap: () {
                            setState(() {
                              for (var c in _chats) {
                                c['unread'] = 0;
                              }
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete_sweep_outlined,
                              color: BizaTheme.accentRed),
                          title: const Text("Delete all conversations",
                              style:
                              TextStyle(color: BizaTheme.accentRed, fontSize: 14)),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: BizaTheme.cardBackground,
                                title: const Text("Delete All",
                                    style: TextStyle(color: Colors.white)),
                                content: const Text(
                                    "Delete all conversations? This cannot be undone.",
                                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel",
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: BizaTheme.accentRed),
                                    onPressed: () {
                                      setState(() => _chats.clear());
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Delete All",
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
              },
            ),
        ],
      ),
      body: _chats.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("No messages yet",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            SizedBox(height: 8),
            Text("Conversations will appear here",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chats.length,
        separatorBuilder: (_, __) => Divider(
          color: Colors.grey.shade900,
          height: 1,
          indent: 76,
        ),
        itemBuilder: (context, index) {
          final chat = chats[index];
          final actualIndex = _chats.indexOf(chat);
          final unread = chat['unread'] as int;
          final pinned = chat['pinned'] == true;

          return InkWell(
            onTap: () => _openChat(actualIndex),
            onLongPress: () => _showOptions(actualIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: BizaTheme.cardBackground,
                    child: const Icon(Icons.person,
                        color: Colors.white70, size: 30),
                  ),
                  const SizedBox(width: 14),

                  // Name + last message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (pinned) ...[
                              const Icon(Icons.push_pin,
                                  color: BizaTheme.primaryGreen, size: 14),
                              const SizedBox(width: 6),
                            ],
                            Text(chat['name'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat['lastMessage'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unread > 0 ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                            fontWeight:
                            unread > 0 ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Time + unread badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(chat['time'],
                          style: TextStyle(
                              color: _timeColor(chat),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: BizaTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("$unread",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        )
                      else
                        const SizedBox(height: 16),
                    ],
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