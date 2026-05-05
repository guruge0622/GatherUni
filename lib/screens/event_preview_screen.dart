import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';

class EventPreviewScreen extends StatelessWidget {
  const EventPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = ModalRoute.of(context)!.settings.arguments as Event?;
    if (event == null) {
      return const Scaffold(body: Center(child: Text('No event to preview')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Preview Event')),
      backgroundColor: GatherColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: event.imageUrl != null
                    ? Image.network(event.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 64),
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text('${event.date} • ${event.time}'),
              const SizedBox(height: 8),
              Text(event.description),
              const SizedBox(height: 18),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final scaffold = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);
                      await addUserEvent(event);
                      scaffold.showSnackBar(
                        const SnackBar(content: Text('Event published')),
                      );
                      nav.pushNamed('/organizer/dashboard');
                    },
                    child: const Text('Confirm & Publish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
