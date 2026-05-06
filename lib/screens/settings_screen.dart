import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';
import '../src/ui/feedback.dart';
import '../src/backend/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LocalProfileData>(
      valueListenable: localProfile,
      builder: (context, profile, _) {
        return Scaffold(
          backgroundColor: GatherColors.background,
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              _SettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Notifications',
                subtitle: 'Get notified about events and updates',
                trailing: Switch(
                  value: profile.eventReminders,
                  onChanged: (value) =>
                      updateLocalProfile(eventReminders: value),
                ),
              ),
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: 'Reduce glare and save battery',
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                ),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).pushNamed('/privacy'),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'Read our terms of service',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).pushNamed('/terms'),
              ),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'Contact support or view FAQs',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).pushNamed('/support'),
              ),
              const SizedBox(height: 6),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6ECF6)),
                ),
                child: TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      UIFeedback.showLoading(
                        context,
                        message: 'Signing out...',
                      );
                      await FirebaseService.instance.signOut();
                      if (nav.canPop()) nav.pop();
                      if (!mounted) return;
                      nav.pushNamedAndRemoveUntil('/login', (r) => false);
                    } catch (e) {
                      if (nav.canPop()) nav.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Sign out failed: ${e.toString()}'),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: const Color(0xFFD23F48),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6ECF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: GatherColors.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: GatherColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GatherColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: GatherColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: child);
    }

    return child;
  }
}
