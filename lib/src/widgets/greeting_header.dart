import 'dart:io';

import 'package:flutter/material.dart';
import '../backend/firebase_service.dart';
import '../theme/design_system.dart';
import '../shared.dart';

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return 'Good morning';
  if (hour >= 12 && hour < 17) return 'Good afternoon';
  if (hour >= 17 && hour < 21) return 'Good evening';
  return 'Good night';
}

Color _greetingColor() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return const Color(0xFFEF8A62); // warm orange
  if (hour >= 12 && hour < 17) return GatherColors.primary; // brand blue
  if (hour >= 17 && hour < 21) return const Color(0xFF7B61FF); // purple
  return const Color(0xFF2D3748); // dark indigo/gray
}

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService.instance.currentUser;
    final firebasePhoto = user?.photoURL;
    final name = localProfile.value.fullName.isNotEmpty
        ? localProfile.value.fullName
        : (user?.displayName ?? 'Guest');

    final greeting = _getGreeting();
    final color = _greetingColor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $name 👋',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Find events for you',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: GatherColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Notification (circular) with badge, matched to avatar size
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.notifications_none,
                        color: color,
                        size: 22,
                      ),
                    ),
                    // red badge
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD23F48),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Profile picture (tappable, top-right)
          InkWell(
            onTap: () => Navigator.of(context).pushNamed('/profile'),
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: ValueListenableBuilder<LocalProfileData>(
                  valueListenable: localProfile,
                  builder: (ctx, profile, _) {
                    ImageProvider<Object>? provider;
                    if (profile.photoPath != null &&
                        profile.photoPath!.isNotEmpty) {
                      provider = FileImage(File(profile.photoPath!));
                    } else if (firebasePhoto != null &&
                        firebasePhoto.isNotEmpty) {
                      provider = NetworkImage(firebasePhoto);
                    }

                    return CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.transparent,
                      foregroundImage: provider,
                      child: provider == null
                          ? Icon(Icons.person, color: color, size: 22)
                          : null,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
