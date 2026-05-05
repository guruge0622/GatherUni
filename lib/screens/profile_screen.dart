import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../src/shared.dart';
import 'event_listing_screen.dart';
import '../src/theme/design_system.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _intakeCtrl = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final intake = localProfile.value.intake;
    _intakeCtrl.text = intake.isEmpty ? '41' : intake;
  }

  @override
  void dispose() {
    _intakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      imageQuality: 86,
    );
    if (image == null) return;
    updateLocalProfile(photoPath: image.path);
  }

  void _setRole(String role) => updateLocalProfile(role: role);

  void _toggleInterest(String interest, List<String> current) {
    final next = List<String>.from(current);
    next.contains(interest) ? next.remove(interest) : next.add(interest);
    updateLocalProfile(interests: next);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LocalProfileData>(
      valueListenable: localProfile,
      builder: (context, profile, _) {
        if (_intakeCtrl.text != profile.intake) {
          _intakeCtrl.text = profile.intake;
        }

        final isStudent = profile.role == 'Student';

        return Scaffold(
          backgroundColor: GatherColors.background,
          appBar: AppBar(title: const Text('Profile Setup')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _ProfileHeader(profile: profile, onPhotoTap: _pickPhoto),
                const SizedBox(height: 18),

                _SectionCard(
                  title: 'Quick Links',
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.confirmation_number_rounded),
                        title: const Text('My Tickets'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () =>
                            Navigator.of(context).pushNamed('/tickets'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.bookmark_border_rounded),
                        title: const Text('Saved Events'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EventListingScreen(
                              showOnlyBookmarked: true,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () =>
                            Navigator.of(context).pushNamed('/settings'),
                      ),
                    ],
                  ),
                ),

                _SectionCard(
                  title: 'Role',
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Student',
                        label: Text('Student'),
                        icon: Icon(Icons.school_rounded),
                      ),
                      ButtonSegment(
                        value: 'Staff',
                        label: Text('Staff'),
                        icon: Icon(Icons.badge_rounded),
                      ),
                      ButtonSegment(
                        value: 'Organizer',
                        label: Text('Organizer'),
                        icon: Icon(Icons.business_center_rounded),
                      ),
                    ],
                    selected: {profile.role},
                    onSelectionChanged: (v) => _setRole(v.first),
                  ),
                ),

                if (isStudent) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Academic Details',
                    child: Column(
                      children: [
                        _ReadOnlyInfoField(
                          label: 'Faculty',
                          value: profile.faculty.isEmpty
                              ? 'Complete signup to auto display faculty'
                              : profile.faculty,
                          icon: Icons.apartment_rounded,
                        ),
                        const SizedBox(height: 12),
                        _ReadOnlyInfoField(
                          label: 'Degree',
                          value: profile.degree.isEmpty
                              ? 'Complete signup to auto display degree'
                              : profile.degree,
                          icon: Icons.workspace_premium_rounded,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _intakeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Intake',
                            hintText: 'Example: 41',
                            prefixIcon: Icon(Icons.calendar_month_rounded),
                          ),
                          onChanged: (value) =>
                              updateLocalProfile(intake: value.trim()),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Interests',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: interests.map((interest) {
                      final selected = profile.interests.contains(interest);
                      return FilterChip(
                        selected: selected,
                        label: Text(interest),
                        avatar: Icon(
                          _interestIcon(interest),
                          size: 17,
                          color: selected ? Colors.white : GatherColors.primary,
                        ),
                        selectedColor: GatherColors.primary,
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : GatherColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: selected
                                ? GatherColors.primary
                                : const Color(0xFFD5DEEF),
                          ),
                        ),
                        onSelected: (_) =>
                            _toggleInterest(interest, profile.interests),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.onPhotoTap});

  final LocalProfileData profile;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final photoPath = profile.photoPath;
    final hasPhoto = photoPath != null && photoPath.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: GatherColors.primary.withValues(alpha: .08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPhotoTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: GatherColors.softBlue,
                  backgroundImage: hasPhoto ? FileImage(File(photoPath)) : null,
                  child: hasPhoto
                      ? null
                      : const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: GatherColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName.isEmpty ? 'Your Name' : profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GatherColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  profile.email.isEmpty
                      ? 'Name auto displays after signup'
                      : profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GatherColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: GatherColors.primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.role,
                    style: const TextStyle(
                      color: GatherColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/profile/edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GatherColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (profile.role != 'Organizer')
                  SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        updateLocalProfile(role: 'Organizer');
                        Navigator.of(context).pushNamed('/profile/edit');
                      },
                      child: const Text('Become an Organizer'),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: GatherColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ReadOnlyInfoField extends StatelessWidget {
  const _ReadOnlyInfoField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
      ),
      child: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: GatherColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

IconData _interestIcon(String interest) {
  switch (interest) {
    case 'Academics':
      return Icons.school_rounded;
    case 'Arts':
      return Icons.palette_rounded;
    case 'Cultural':
      return Icons.diversity_3_rounded;
    case 'Sports':
      return Icons.sports_soccer_rounded;
    case 'Tech':
      return Icons.memory_rounded;
    default:
      return Icons.star_rounded;
  }
}
