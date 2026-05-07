import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';
import '../src/backend/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

enum TicketFilter { all, upcoming, past }

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  TicketFilter _filter = TicketFilter.all;

  List<Color> _colorsFromEvent(Map<String, dynamic>? event) {
    if (event == null) return sampleEvents.first.colors;
    final raw = event['colors'];
    try {
      if (raw is List<Color>) return raw;
      if (raw is List) {
        final parsed = <Color>[];
        for (final e in raw) {
          if (e is Color)
            parsed.add(e);
          else if (e is String) {
            var s = e.trim();
            if (s.startsWith('#')) s = s.replaceFirst('#', '0xFF');
            if (s.startsWith('0x'))
              parsed.add(Color(int.parse(s)));
            else
              parsed.add(Color(int.parse('0xFF' + s)));
          }
        }
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (_) {}
    return sampleEvents.first.colors;
  }

  Future<Uint8List> _renderQrToPng(String data, int size) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      color: Colors.black,
      emptyColor: Colors.white,
    );

    final picData = await painter.toImageData(
      size.toDouble(),
      format: ui.ImageByteFormat.png,
    );
    if (picData == null) throw Exception('Failed to render QR image');
    return picData.buffer.asUint8List();
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('MMMM d, yyyy').parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  List<Event> _filteredEvents() {
    final now = DateTime.now();
    switch (_filter) {
      case TicketFilter.upcoming:
        return sampleEvents
            .where((e) => _parseDate(e.date).isAfter(now))
            .toList();
      case TicketFilter.past:
        return sampleEvents
            .where((e) => _parseDate(e.date).isBefore(now))
            .toList();
      case TicketFilter.all:
        return sampleEvents.toList();
    }
  }

  Widget _buildFilterTabs() {
    Widget tab(String label, TicketFilter value) {
      final selected = _filter == value;
      return GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? GatherColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : GatherColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: GatherColors.withOpacity(Colors.black, .03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tab('All', TicketFilter.all),
          const SizedBox(width: 8),
          tab('Upcoming', TicketFilter.upcoming),
          const SizedBox(width: 8),
          tab('Past', TicketFilter.past),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseService.instance.currentUser ??
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: GatherColors.background,
      appBar: AppBar(title: const Text('My Tickets')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          children: [
            _buildFilterTabs(),
            const SizedBox(height: 14),
            if (user == null)
              Expanded(
                child: Center(
                  child: Text(
                    'Sign in to view your tickets',
                    style: TextStyle(color: GatherColors.textSecondary),
                  ),
                ),
              )
            else
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirebaseService.instance.streamUserBookings(user.uid),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = snap.data ?? [];
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'No tickets found',
                            style: TextStyle(color: GatherColors.textSecondary),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final item = items[idx];
                        final event = item['event'] as Map<String, dynamic>?;
                        final booking =
                            item['booking'] as Map<String, dynamic>?;
                        final title = event?['title'] as String? ?? 'Event';
                        final date = event?['date'] as String? ?? '';
                        final time = event?['time'] as String? ?? '';
                        final location = event?['location'] as String? ?? '';
                        final isPast = () {
                          try {
                            final parsed = _parseDate(date);
                            return parsed.isBefore(DateTime.now());
                          } catch (_) {
                            return false;
                          }
                        }();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: GatherColors.withOpacity(
                                  Colors.black,
                                  .03,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // thumbnail
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _colorsFromEvent(event),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.event,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        color: GatherColors.textPrimary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$date • $time',
                                      style: const TextStyle(
                                        color: GatherColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isPast ? 'Past event' : '1 Ticket',
                                      style: TextStyle(
                                        color: isPast
                                            ? Colors.grey
                                            : GatherColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // QR and actions
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_2_rounded,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    tooltip: 'Share ticket',
                                    onPressed: () {
                                      final eventId =
                                          item['eventId'] as String? ?? '';
                                      final shareText = StringBuffer()
                                        ..writeln('Ticket: $title')
                                        ..writeln('$date • $time')
                                        ..writeln(location)
                                        ..writeln()
                                        ..writeln('Event ID: $eventId');

                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Share Ticket'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              QrImage(
                                                data: shareText.toString(),
                                                size: 190,
                                                backgroundColor: Colors.white,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Scan to import ticket or share it via your apps.',
                                                style: TextStyle(
                                                  color: GatherColors
                                                      .textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                              child: const Text('Close'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  final bytes =
                                                      await _renderQrToPng(
                                                        shareText.toString(),
                                                        800,
                                                      );
                                                  final dir =
                                                      await getTemporaryDirectory();
                                                  final file = File(
                                                    '${dir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png',
                                                  );
                                                  await file.writeAsBytes(
                                                    bytes,
                                                  );
                                                  await Share.shareFiles(
                                                    [file.path],
                                                    text: shareText.toString(),
                                                  );
                                                } catch (e) {
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Failed to export QR: ${e.toString()}',
                                                      ),
                                                    ),
                                                  );
                                                }
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text(
                                                'Save & Share Image',
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Share.share(
                                                  shareText.toString(),
                                                );
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text('Share'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.ios_share_rounded),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
