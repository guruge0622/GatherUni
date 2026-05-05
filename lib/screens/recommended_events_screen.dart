import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';
import 'event_detail_screen.dart';

class RecommendedEventsScreen extends StatelessWidget {
  const RecommendedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = localProfile.value;
    final events = sampleEvents.where((event) {
      return profile.interests.isEmpty ||
          profile.interests.contains(event.category);
    }).toList();

    return Scaffold(
      backgroundColor: GatherColors.background,
      appBar: AppBar(title: const Text('Recommended')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE6ECF6)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended for You',
                  style: TextStyle(
                    color: GatherColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Based on your interests',
                  style: TextStyle(
                    color: GatherColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: events
                      .take(3)
                      .map((e) => _RecommendedRow(event: e))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Center(
                  child: SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/events'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F2FB),
                        foregroundColor: GatherColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('View More'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedRow extends StatelessWidget {
  const _RecommendedRow({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: event.colors),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.auto_awesome_rounded, color: Colors.white),
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
                      color: GatherColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.date} • ${event.time} • ${event.location}',
                    style: const TextStyle(
                      color: GatherColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF8D98A8)),
          ],
        ),
      ),
    );
  }
}
