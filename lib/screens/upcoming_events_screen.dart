import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../src/shared.dart';
import '../src/backend/firebase_service.dart';
import 'event_detail_screen.dart';

class UpcomingEventsScreen extends StatefulWidget {
  final String? category;
  const UpcomingEventsScreen({super.key, this.category});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  List<Event> _liveEvents = [];
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FirebaseService.instance.streamAllEvents().listen((snap) {
      final events = snap.docs
          .map((d) => Event.fromMap({'id': d.id, ...d.data()}))
          .toList();
      if (mounted) setState(() => _liveEvents = events);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<Event> _merged() {
    final base = _liveEvents.isEmpty ? sampleEvents : _liveEvents;
    final merged = List<Event>.from(base);
    for (final e in userEvents.value) {
      if (e.id.isEmpty) {
        merged.insert(0, e);
        continue;
      }
      final exists = merged.any((me) => me.id == e.id);
      if (!exists) merged.insert(0, e);
    }
    return merged;
  }

  List<Event> _upcoming() {
    final df = DateFormat('MMMM d, y');
    final now = DateTime.now();
    final merged = _merged();
    final list = merged.where((e) {
      try {
        final dt = df.parse(e.date);
        return !dt.isBefore(now);
      } catch (_) {
        return true;
      }
    }).toList();
    // Apply category filter from the widget argument if provided
    if (widget.category != null && widget.category != 'All') {
      final filtered = list
          .where((e) => e.category == widget.category)
          .toList();
      filtered.sort((a, b) {
        try {
          final da = df.parse(a.date);
          final db = df.parse(b.date);
          return da.compareTo(db);
        } catch (_) {
          return 0;
        }
      });
      return filtered;
    }
    list.sort((a, b) {
      try {
        final da = df.parse(a.date);
        final db = df.parse(b.date);
        return da.compareTo(db);
      } catch (_) {
        return 0;
      }
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _upcoming();
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events')),
      body: RefreshIndicator(
        onRefresh: () async {
          // Force rebuild by awaiting a tiny delay; live stream will update automatically
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: upcoming.length,
          itemBuilder: (context, i) {
            final e = upcoming[i];
            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EventDetailScreen(event: e)),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE6ECF6)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: e.imageUrl != null
                          ? Image.network(
                              e.imageUrl!,
                              width: 100,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: e.colors),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.event,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${e.date} • ${e.time}',
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              e.location,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
