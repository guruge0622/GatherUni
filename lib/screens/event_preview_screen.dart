import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';

class EventPreviewScreen extends StatelessWidget {
  const EventPreviewScreen({super.key});

              if (isEventOwnedByCurrentUser(event))
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          UIFeedback.showLoading(context, message: 'Publishing...');
                          await addUserEvent(event);
                          UIFeedback.hideLoading(context);
                          if (!mounted) return;
                          UIFeedback.showSnack(context, 'Event published');
                          Navigator.of(context).pushNamed('/organizer/dashboard');
                        } catch (e) {
                          UIFeedback.hideLoading(context);
                          UIFeedback.showSnack(context, 'Publish failed: ${e.toString()}', success: false);
                        }
                      },
                      child: const Text('Confirm & Publish'),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
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
                      try {
                        UIFeedback.showLoading(
                          context,
                          message: 'Publishing...',
                        );
                        await addUserEvent(event);
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
