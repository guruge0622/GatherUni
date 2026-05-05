import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';

enum TicketFilter { all, upcoming, past }

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  TicketFilter _filter = TicketFilter.all;

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
    final events = _filteredEvents();

    return Scaffold(
      backgroundColor: GatherColors.background,
      appBar: AppBar(title: const Text('My Tickets')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          _buildFilterTabs(),
          const SizedBox(height: 14),
          if (events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'No tickets found',
                  style: TextStyle(color: GatherColors.textSecondary),
                ),
              ),
            ),
          ...events.map((event) {
            final isPast = _parseDate(event.date).isBefore(DateTime.now());
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: GatherColors.withOpacity(Colors.black, .03),
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
                      gradient: LinearGradient(colors: event.colors),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.event, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: GatherColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${event.date} • ${event.time}',
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
                            color: isPast ? Colors.grey : GatherColors.primary,
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
                        onPressed: () {},
                        icon: const Icon(Icons.ios_share_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
