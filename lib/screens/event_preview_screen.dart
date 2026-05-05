import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';
import '../src/ui/feedback.dart';

class EventPreviewScreen extends StatefulWidget {
  const EventPreviewScreen({super.key, required this.event});

  final Event event;

  @override
  State<EventPreviewScreen> createState() => _EventPreviewScreenState();
}

class _EventPreviewScreenState extends State<EventPreviewScreen> {
  Future<void> _publish() async {
    try {
      UIFeedback.showLoading(context, message: 'Publishing...');
      await addUserEvent(widget.event);
      UIFeedback.hideLoading(context);
      if (!mounted) return;
      UIFeedback.showSnack(context, 'Event published');
      Navigator.of(context).pushNamed('/organizer/dashboard');
    } catch (e) {
      UIFeedback.hideLoading(context);
      UIFeedback.showSnack(
        context,
        'Publish failed: ${e.toString()}',
        success: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final owned = isEventOwnedByCurrentUser(event);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              const SizedBox(
                height: 180,
                child: Center(child: Icon(Icons.image, size: 64)),
              ),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text('${event.date} • ${event.time}'),
            const SizedBox(height: 8),
            Text(event.description),
            const SizedBox(height: 18),
            if (owned)
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _publish,
                    child: const Text('Confirm & Publish'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
