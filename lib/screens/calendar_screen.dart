import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';
import 'event_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    userEvents.addListener(_onUserEventsChanged);
  }

  void _onUserEventsChanged() => setState(() {});

  @override
  void dispose() {
    userEvents.removeListener(_onUserEventsChanged);
    super.dispose();
  }

  Map<DateTime, List<Event>> _eventsForDate() {
    final map = <DateTime, List<Event>>{};
    final all = [...sampleEvents, ...userEvents.value.where((e) => !e.isDraft)];
    for (final e in all) {
      try {
        final dt = DateFormat('MMMM d, yyyy').parse(e.date);
        final key = DateTime(dt.year, dt.month, dt.day);
        map.putIfAbsent(key, () => []).add(e);
      } catch (_) {}
    }
    return map;
  }

  List<Event> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final map = _eventsForDate();
    return map[key] ?? [];
  }

  List<Event> _upcomingEvents() {
    final now = DateTime.now();
    final all = [...sampleEvents, ...userEvents.value.where((e) => !e.isDraft)];
    final list = all.where((e) {
      try {
        final dt = DateFormat('MMMM d, yyyy').parse(e.date);
        return dt.isAfter(now) ||
            DateTime(dt.year, dt.month, dt.day) ==
                DateTime(now.year, now.month, now.day);
      } catch (_) {
        return false;
      }
    }).toList();
    list.sort((a, b) {
      final da = DateFormat('MMMM d, yyyy').parse(a.date);
      final db = DateFormat('MMMM d, yyyy').parse(b.date);
      return da.compareTo(db);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    _eventsForDate();
    final selected = _selectedDay ?? _focusedDay;
    final todaysEvents = _getEventsForDay(selected);
    final upcoming = _upcomingEvents();

    return Scaffold(
      backgroundColor: GatherColors.background,
      appBar: AppBar(title: const Text('Calendar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          // Calendar header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: GatherColors.withOpacity(Colors.black, .03),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                TableCalendar<Event>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) => _getEventsForDay(day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: GatherColors.softBlue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: GatherColors.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: GatherColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Events on selected day
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Events on ${DateFormat.yMMMMd().format(selected)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 8),
                if (todaysEvents.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GatherColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('No events for this date'),
                  )
                else
                  Column(
                    children: todaysEvents
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EventDetailScreen(event: e),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${e.time} • ${e.location}',
                                            style: const TextStyle(
                                              color: GatherColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Upcoming events (persistent)
          Text(
            'Upcoming Events',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...upcoming.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventDetailScreen(event: event),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: event.colors),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${event.date} • ${event.time}',
                              style: const TextStyle(
                                color: GatherColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.ios_share_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
