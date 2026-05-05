import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';

enum NotificationType { reminder, booking, update }

class NotificationEntry {
  NotificationEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String time;
  bool read;
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationEntry> _items;

  void _rebuildFromEvents() {
    final published = userEvents.value.where((e) => !e.isDraft).toList();
    final notifs = <NotificationEntry>[];
    // Create notifications for published user events (most recent first)
    for (var i = published.length - 1; i >= 0; i--) {
      final e = published[i];
      notifs.add(
        NotificationEntry(
          id: 'ue_${e.id}',
          type: NotificationType.update,
          title: 'New event posted',
          body: '${e.title} • ${e.date} ${e.time}',
          time: 'just now',
        ),
      );
    }
    // Keep a few sample-based notifications as well
    notifs.addAll([
      NotificationEntry(
        id: 's1',
        type: NotificationType.reminder,
        title: 'Reminder',
        body:
            '${sampleEvents.first.title} starts at ${sampleEvents.first.time}.',
        time: '1h ago',
      ),
      NotificationEntry(
        id: 's2',
        type: NotificationType.booking,
        title: 'Booking Confirmed',
        body: 'Your booking for ${sampleEvents[0].title} is confirmed.',
        time: '2h ago',
      ),
    ]);
    setState(() => _items = notifs);
  }

  @override
  void initState() {
    super.initState();
    _items = [];
    _rebuildFromEvents();
    userEvents.addListener(_rebuildFromEvents);
  }

  @override
  void dispose() {
    userEvents.removeListener(_rebuildFromEvents);
    super.dispose();
  }

  Color _colorForType(NotificationType t) {
    switch (t) {
      case NotificationType.reminder:
        return const Color(0xFFF59E0B);
      case NotificationType.booking:
        return const Color(0xFF10B981);
      case NotificationType.update:
        return const Color(0xFFEF4444);
    }
  }

  IconData _iconForType(NotificationType t) {
    switch (t) {
      case NotificationType.reminder:
        return Icons.notifications_active_rounded;
      case NotificationType.booking:
        return Icons.confirmation_number_rounded;
      case NotificationType.update:
        return Icons.info_rounded;
    }
  }

  void _dismissItem(int index) {
    final removed = _items.removeAt(index);
    setState(() {});
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dismissed "${removed.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _items.insert(index, removed);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GatherColors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: GatherColors.withOpacity(Colors.black, .03),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'No notifications',
                            style: TextStyle(color: GatherColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: List.generate(_items.length, (i) {
                          final item = _items[i];
                          return Column(
                            children: [
                              Dismissible(
                                key: ValueKey(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: GatherColors.withOpacity(
                                      Colors.red,
                                      .9,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) => _dismissItem(i),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: item.read
                                        ? Colors.white
                                        : GatherColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: GatherColors.withOpacity(
                                            _colorForType(item.type),
                                            .12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          _iconForType(item.type),
                                          color: _colorForType(item.type),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.title,
                                                    style: TextStyle(
                                                      color: GatherColors
                                                          .textPrimary,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  item.time,
                                                  style: const TextStyle(
                                                    color: GatherColors
                                                        .textSecondary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              item.body,
                                              style: const TextStyle(
                                                color:
                                                    GatherColors.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: item.read
                                                ? 'Mark as unread'
                                                : 'Mark as read',
                                            onPressed: () {
                                              setState(
                                                () => item.read = !item.read,
                                              );
                                            },
                                            icon: Icon(
                                              item.read
                                                  ? Icons.mark_email_read
                                                  : Icons.mark_email_unread,
                                              color: item.read
                                                  ? Colors.grey
                                                  : GatherColors.primary,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Share',
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.ios_share_rounded,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (i != _items.length - 1)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Divider(height: 1),
                                ),
                            ],
                          );
                        }),
                      ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
