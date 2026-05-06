import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';

const _facultyDegrees = {
  'Faculty of Defence and Strategic Studies (FDSS)': [
    'Bachelor of Science in Strategic Studies and International Relations',
  ],
  'Faculty of Medicine (FOM)': [
    'Bachelor of Medicine and Bachelor of Surgery (MBBS)',
  ],
  'Faculty of Engineering (FOE)': [
    'BSc (Hons) in Aeronautical Engineering',
    'BSc (Hons) in Building Services Engineering',
    'BSc (Hons) in Civil Engineering',
    'BSc (Hons) in Electrical and Electronic Engineering',
    'BSc (Hons) in Electronic and Telecommunication Engineering',
    'BSc (Hons) in Mechanical Engineering',
    'BSc (Hons) in Mechatronic Engineering',
    'BSc (Hons) in Marine Engineering',
    'BSc (Hons) in Naval Architecture and Marine Engineering',
  ],
  'Faculty of Law (FOL)': ['Bachelor of Laws (LLB)'],
  'Faculty of Management, Social Sciences and Humanities (FMSH)': [
    'BSc in Management and Technical Sciences',
    'BSc (Hons) in Management and Technical Sciences',
    'BSc in Logistics Management',
    'BSc in Social Sciences',
    'BA in Teaching English to Speakers of Other Languages (TESOL)',
    'BSc (Hons) in Financial Analytics',
    'BSc (Hons) in Management',
  ],
  'Faculty of Computing (FOC)': [
    'BSc (Hons) in Computer Science',
    'BSc (Hons) in Software Engineering',
    'BSc (Hons) in Computer Engineering',
    'BSc (Hons) in Information Technology',
  ],
  'Faculty of Criminal Justice (FOCJ)': [
    'BSc in Criminology and Criminal Justice',
  ],
  'Faculty of Technology': [
    'BET (Hons) in Biomedical Instrumentation Technology',
    'BET (Hons) in Building Services Technology',
    'BT (Hons) in Information and Communication Technology',
    'BBST (Hons) in Applied Biotechnology',
    'BET (Hons) in Construction Technology',
  ],
  'Other': ['Other'],
};

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final _controller = PageController();
  final _picker = ImagePicker();
  final _nameCtrl = TextEditingController();
  final _facultyCtrl = TextEditingController();
  int _page = 0;

  static const _academicYears = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Postgraduate',
  ];

  @override
  void initState() {
    super.initState();
    final profile = localProfile.value;
    _nameCtrl.text = profile.fullName;
    _facultyCtrl.text = profile.faculty;
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    _facultyCtrl.dispose();
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

  void _goNext() {
    final profile = localProfile.value;

    if (_page == 4) {
      Navigator.of(context).pushReplacementNamed('/main');
      return;
    }

    // Page 1: require name and faculty
    if (_page == 1) {
      if (profile.fullName.trim().isEmpty || profile.faculty.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name and faculty.')),
        );
        return;
      }

      if (profile.role == 'Student') {
        if (profile.degree.trim().isEmpty ||
            profile.academicYear.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select your degree and academic year.'),
            ),
          );
          return;
        }
      }
    }

    // Page 2: require at least one interest
    if (_page == 2) {
      if (profile.interests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one interest.')),
        );
        return;
      }
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _goBack() {
    if (_page == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    _controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LocalProfileData>(
      valueListenable: localProfile,
      builder: (context, profile, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [GatherColors.background, GatherColors.softBlue],
              ),
            ),
            // ignore: deprecated_member_use
            child: WillPopScope(
              onWillPop: () async => false,
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          if (_page == 0)
                            const SizedBox(width: 48)
                          else
                            IconButton(
                              onPressed: _goBack,
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          Expanded(child: _ProgressDots(activeIndex: _page)),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _controller,
                        onPageChanged: (index) => setState(() => _page = index),
                        children: [
                          _WelcomePage(onNext: _goNext),
                          _ProfileInfoPage(
                            profile: profile,
                            nameCtrl: _nameCtrl,
                            facultyCtrl: _facultyCtrl,
                            academicYears: _academicYears,
                            onPhotoTap: _pickPhoto,
                          ),
                          _InterestsPage(profile: profile),
                          _PreferencesPage(profile: profile),
                          _CompletionPage(onFinish: _goNext),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
                      child: _page == 3
                          ? ElevatedButton(
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await saveLocalProfile();
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Setup saved')),
                                );
                                _goNext();
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text('Save'),
                            )
                          : const SizedBox(height: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      centerContent: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GatherUniLogo(size: 124),
          const SizedBox(height: 28),
          const Text(
            'GatherUni',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GatherColors.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Discover university events that match your passion',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GatherColors.textSecondary,
              fontSize: 17,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(210, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoPage extends StatelessWidget {
  const _ProfileInfoPage({
    required this.profile,
    required this.nameCtrl,
    required this.facultyCtrl,
    required this.academicYears,
    required this.onPhotoTap,
  });

  final LocalProfileData profile;
  final TextEditingController nameCtrl;
  final TextEditingController facultyCtrl;
  final List<String> academicYears;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final photoPath = profile.photoPath;
    final hasPhoto = photoPath != null && photoPath.isNotEmpty;

    return _OnboardingPage(
      title: 'Basic Profile',
      subtitle: 'Set up the details that help personalize your feed.',
      child: _FormCard(
        child: Column(
          children: [
            GestureDetector(
              onTap: onPhotoTap,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: GatherColors.softBlue,
                    backgroundImage: hasPhoto
                        ? FileImage(File(photoPath))
                        : null,
                    child: hasPhoto
                        ? null
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: GatherColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              onChanged: (value) => updateLocalProfile(fullName: value.trim()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: profile.role.isEmpty ? 'Student' : profile.role,
              items: const [
                DropdownMenuItem(value: 'Student', child: Text('Student')),
                DropdownMenuItem(value: 'Staff', child: Text('Staff')),
              ],
              onChanged: (v) => updateLocalProfile(role: v ?? 'Student'),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: profile.faculty.isEmpty ? null : profile.faculty,
              isExpanded: true,
              items: _facultyDegrees.keys
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) {
                updateLocalProfile(faculty: v ?? '');
                // clear degree when faculty changes
                updateLocalProfile(degree: '');
              },
              decoration: const InputDecoration(
                labelText: 'Faculty / Department',
                prefixIcon: Icon(Icons.apartment_rounded),
              ),
            ),
            const SizedBox(height: 12),
            // Degree (only for students)
            if (profile.role == 'Student') ...[
              DropdownButtonFormField<String>(
                initialValue: profile.degree.isEmpty ? null : profile.degree,
                isExpanded: true,
                items:
                    (profile.faculty.isNotEmpty &&
                        _facultyDegrees[profile.faculty] != null)
                    ? _facultyDegrees[profile.faculty]!
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList()
                    : [],
                onChanged: profile.faculty.isEmpty
                    ? null
                    : (v) => updateLocalProfile(degree: v ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Degree',
                  prefixIcon: Icon(Icons.school_rounded),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (profile.role == 'Student') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: profile.academicYear.isEmpty
                    ? null
                    : profile.academicYear,
                isExpanded: true,
                items: academicYears
                    .map(
                      (year) =>
                          DropdownMenuItem(value: year, child: Text(year)),
                    )
                    .toList(),
                onChanged: (value) =>
                    updateLocalProfile(academicYear: value ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  prefixIcon: Icon(Icons.calendar_month_rounded),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InterestsPage extends StatelessWidget {
  const _InterestsPage({required this.profile});

  final LocalProfileData profile;

  static const _interestLabels = {
    'Academics': 'Academics & Professional',
    'Tech': 'Tech & Innovation',
    'Arts': 'Art & Entertainment',
    'Sports': 'Sports & Fitness',
    'Cultural': 'Social & Cultural',
  };

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      title: 'Choose Interests',
      subtitle: 'Your recommendations become smarter with every selection.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _interestLabels.entries.map((entry) {
          final selected = profile.interests.contains(entry.key);
          return FilterChip(
            selected: selected,
            label: Text(entry.value),
            avatar: Icon(
              _interestIcon(entry.key),
              color: selected ? Colors.white : GatherColors.primary,
              size: 18,
            ),
            selectedColor: GatherColors.primary,
            backgroundColor: Colors.white,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : GatherColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: selected
                    ? GatherColors.primary
                    : const Color(0xFFD5DEEF),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            onSelected: (_) {
              final next = List<String>.from(profile.interests);
              next.contains(entry.key)
                  ? next.remove(entry.key)
                  : next.add(entry.key);
              updateLocalProfile(interests: next);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _PreferencesPage extends StatelessWidget {
  const _PreferencesPage({required this.profile});

  final LocalProfileData profile;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      title: 'Preferences',
      subtitle: 'Fine tune how GatherUni keeps you in the loop.',
      child: _FormCard(
        child: Column(
          children: [
            _PreferenceSwitch(
              icon: Icons.notifications_active_rounded,
              title: 'Event reminders',
              subtitle: 'Receive reminders before saved events.',
              value: profile.eventReminders,
              onChanged: (value) => updateLocalProfile(eventReminders: value),
            ),
            const Divider(height: 24),
            _PreferenceSwitch(
              icon: Icons.trending_up_rounded,
              title: 'Trending events',
              subtitle: 'Show popular events in your recommendations.',
              value: profile.trendingEvents,
              onChanged: (value) => updateLocalProfile(trendingEvents: value),
            ),
            const Divider(height: 24),
            _PreferenceSwitch(
              icon: Icons.location_on_rounded,
              title: 'Location access',
              subtitle: 'Use location for nearby university events.',
              value: profile.locationAccess,
              onChanged: (value) => updateLocalProfile(locationAccess: value),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CompletionPage extends StatefulWidget {
  const _CompletionPage({required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<_CompletionPage> createState() => _CompletionPageState();
}

class _CompletionPageState extends State<_CompletionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          widget.onFinish();
        });
      }
    });
  }

  late final Animation<double> _scaleAnim = CurvedAnimation(
    parent: _animation,
    curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
  );

  late final Animation<double> _textFade = CurvedAnimation(
    parent: _animation,
    curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
  );

  late final Animation<Offset> _textSlide =
      Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animation,
          curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
        ),
      );
  late final Animation<double> _circleFade = CurvedAnimation(
    parent: _animation,
    curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
  );

  // Icon pop/fade
  late final Animation<double> _iconScale = Tween<double>(begin: 0.2, end: 1.0)
      .animate(
        CurvedAnimation(
          parent: _animation,
          curve: const Interval(0.35, 0.65, curve: Curves.elasticOut),
        ),
      );

  late final Animation<double> _iconFade = CurvedAnimation(
    parent: _animation,
    curve: const Interval(0.35, 0.65, curve: Curves.easeIn),
  );

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      centerContent: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _circleFade,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 116,
                height: 116,
                decoration: const BoxDecoration(
                  color: GatherColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FadeTransition(
                    opacity: _iconFade,
                    child: ScaleTransition(
                      scale: _iconScale,
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeTransition(
            opacity: _textFade,
            child: SlideTransition(
              position: _textSlide,
              child: const Text(
                'You are all set!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GatherColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeTransition(
            opacity: _textFade,
            child: SlideTransition(
              position: _textSlide,
              child: const Text(
                'Personalized recommendations are ready for your next campus event.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GatherColors.textSecondary,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    this.title,
    this.subtitle,
    this.centerContent = false,
    required this.child,
  });

  final String? title;
  final String? subtitle;
  final bool centerContent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (centerContent) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 28,
              ),
              child: Center(child: child),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  color: GatherColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: const TextStyle(
                  color: GatherColors.textSecondary,
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
            ],
            child,
          ],
        );
      },
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6ECF6)),
        boxShadow: [
          BoxShadow(
            color: GatherColors.primary.withValues(alpha: .08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
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
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: GatherColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: active ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active ? GatherColors.primary : GatherColors.lightBlue,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

IconData _interestIcon(String interest) {
  switch (interest) {
    case 'Academics':
      return Icons.menu_book_rounded;
    case 'Tech':
      return Icons.memory_rounded;
    case 'Arts':
      return Icons.theater_comedy_rounded;
    case 'Sports':
      return Icons.sports_soccer_rounded;
    case 'Cultural':
      return Icons.public_rounded;
    default:
      return Icons.star_rounded;
  }
}
