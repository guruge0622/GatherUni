import 'package:flutter/material.dart';
import '../src/theme/design_system.dart';
import '../src/shared.dart';
import 'ticket_booking_screen.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Container(
        color: GatherColors.background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: event.colors),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(Icons.event, color: Colors.white, size: 72),
              ),
            ),
            const SizedBox(height: 16),
            Text(event.title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: GatherColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text('${event.date} • ${event.time}'),
                const Spacer(),
                Text(
                  event.price == 0
                      ? 'Free'
                      : '\$${event.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: GatherColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Location', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(event.location, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Description', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TicketBookingScreen(event: event),
                ),
              ),
              child: const Text('Book Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}
