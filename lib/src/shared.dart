import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/src/backend/firebase_service.dart';

class AppColors {
  static const primaryBlue = Color(0xFF395886);
  static const secondaryGreen = Color(0xFF638ECB);
  static const accentYellow = Color(0xFF8AAEE0);
  static const lightBlue = Color(0xFFB1C9EF);
  static const background = Color(0xFFF0F3FA);
  static const inputBorder = Color(0xFFB1C9EF);
  static const softBlue = Color(0xFFD5DEEF);
  static const text = Color(0xFF24364F);
  static const mutedText = Color(0xFF638ECB);
  static const card = Colors.white;
}

// Removed custom `withValues` extension to avoid clashing with Flutter SDK
// Use the built-in `withOpacity()` instead where needed.

const interests = ['Academics', 'Arts', 'Cultural', 'Sports', 'Tech'];

class LocalProfileData {
  LocalProfileData({
    this.fullName = '',
    this.email = '',
    this.role = 'Student',
    this.university = '',
    this.faculty = '',
    this.degree = '',
    this.academicYear = '',
    this.intake = '',
    this.photoPath,
    this.organizationName = '',
    this.organizationLogoPath,
    this.contactInfo = '',
    this.eventReminders = true,
    this.trendingEvents = true,
    this.locationAccess = false,
    List<String>? interests,
  }) : interests = interests ?? <String>[];

  String fullName;
  String email;
  String role;
  String university;
  String faculty;
  String degree;
  String academicYear;
  String intake;
  String? photoPath;
  String organizationName;
  String? organizationLogoPath;
  String contactInfo;
  bool eventReminders;
  bool trendingEvents;
  bool locationAccess;
  List<String> interests;

  LocalProfileData copyWith({
    String? fullName,
    String? email,
    String? role,
    String? university,
    String? faculty,
    String? degree,
    String? academicYear,
    String? intake,
    String? photoPath,
    String? organizationName,
    String? organizationLogoPath,
    String? contactInfo,
    bool? eventReminders,
    bool? trendingEvents,
    bool? locationAccess,
    List<String>? interests,
  }) {
    return LocalProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      degree: degree ?? this.degree,
      academicYear: academicYear ?? this.academicYear,
      intake: intake ?? this.intake,
      photoPath: photoPath ?? this.photoPath,
      organizationName: organizationName ?? this.organizationName,
      organizationLogoPath: organizationLogoPath ?? this.organizationLogoPath,
      contactInfo: contactInfo ?? this.contactInfo,
      eventReminders: eventReminders ?? this.eventReminders,
      trendingEvents: trendingEvents ?? this.trendingEvents,
      locationAccess: locationAccess ?? this.locationAccess,
      interests: interests ?? List<String>.from(this.interests),
    );
  }
}

final localProfile = ValueNotifier<LocalProfileData>(LocalProfileData());
const _profilePrefsPrefix = 'localProfile.';

Future<void> loadLocalProfile() async {
  final prefs = await SharedPreferences.getInstance();
  localProfile.value = LocalProfileData(
    fullName: prefs.getString('${_profilePrefsPrefix}fullName') ?? '',
    email: prefs.getString('${_profilePrefsPrefix}email') ?? '',
    role: prefs.getString('${_profilePrefsPrefix}role') ?? 'Student',
    university: prefs.getString('${_profilePrefsPrefix}university') ?? '',
    faculty: prefs.getString('${_profilePrefsPrefix}faculty') ?? '',
    degree: prefs.getString('${_profilePrefsPrefix}degree') ?? '',
    academicYear: prefs.getString('${_profilePrefsPrefix}academicYear') ?? '',
    intake: prefs.getString('${_profilePrefsPrefix}intake') ?? '',
    photoPath: prefs.getString('${_profilePrefsPrefix}photoPath'),
    organizationName:
        prefs.getString('${_profilePrefsPrefix}organizationName') ?? '',
    organizationLogoPath: prefs.getString(
      '${_profilePrefsPrefix}organizationLogoPath',
    ),
    contactInfo: prefs.getString('${_profilePrefsPrefix}contactInfo') ?? '',
    eventReminders:
        prefs.getBool('${_profilePrefsPrefix}eventReminders') ?? true,
    trendingEvents:
        prefs.getBool('${_profilePrefsPrefix}trendingEvents') ?? true,
    locationAccess:
        prefs.getBool('${_profilePrefsPrefix}locationAccess') ?? false,
    interests: prefs.getStringList('${_profilePrefsPrefix}interests') ?? [],
  );
}

Future<void> saveLocalProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final profile = localProfile.value;
  await prefs.setString('${_profilePrefsPrefix}fullName', profile.fullName);
  await prefs.setString('${_profilePrefsPrefix}email', profile.email);
  await prefs.setString('${_profilePrefsPrefix}role', profile.role);
  await prefs.setString('${_profilePrefsPrefix}university', profile.university);
  await prefs.setString('${_profilePrefsPrefix}faculty', profile.faculty);
  await prefs.setString('${_profilePrefsPrefix}degree', profile.degree);
  await prefs.setString(
    '${_profilePrefsPrefix}academicYear',
    profile.academicYear,
  );
  await prefs.setString('${_profilePrefsPrefix}intake', profile.intake);
  if (profile.photoPath == null || profile.photoPath!.isEmpty) {
    await prefs.remove('${_profilePrefsPrefix}photoPath');
  } else {
    await prefs.setString(
      '${_profilePrefsPrefix}photoPath',
      profile.photoPath!,
    );
  }
  await prefs.setString(
    '${_profilePrefsPrefix}organizationName',
    profile.organizationName,
  );
  if (profile.organizationLogoPath == null ||
      profile.organizationLogoPath!.isEmpty) {
    await prefs.remove('${_profilePrefsPrefix}organizationLogoPath');
  } else {
    await prefs.setString(
      '${_profilePrefsPrefix}organizationLogoPath',
      profile.organizationLogoPath!,
    );
  }
  await prefs.setString(
    '${_profilePrefsPrefix}contactInfo',
    profile.contactInfo,
  );
  await prefs.setBool(
    '${_profilePrefsPrefix}eventReminders',
    profile.eventReminders,
  );
  await prefs.setBool(
    '${_profilePrefsPrefix}trendingEvents',
    profile.trendingEvents,
  );
  await prefs.setBool(
    '${_profilePrefsPrefix}locationAccess',
    profile.locationAccess,
  );
  await prefs.setStringList(
    '${_profilePrefsPrefix}interests',
    profile.interests,
  );
}

void updateLocalProfile({
  String? fullName,
  String? email,
  String? role,
  String? university,
  String? faculty,
  String? degree,
  String? academicYear,
  String? intake,
  String? photoPath,
  String? organizationName,
  String? organizationLogoPath,
  String? contactInfo,
  bool? eventReminders,
  bool? trendingEvents,
  bool? locationAccess,
  List<String>? interests,
}) {
  localProfile.value = localProfile.value.copyWith(
    fullName: fullName,
    email: email,
    role: role,
    university: university,
    faculty: faculty,
    degree: degree,
    academicYear: academicYear,
    intake: intake,
    photoPath: photoPath,
    organizationName: organizationName,
    organizationLogoPath: organizationLogoPath,
    contactInfo: contactInfo,
    eventReminders: eventReminders,
    trendingEvents: trendingEvents,
    locationAccess: locationAccess,
    interests: interests,
  );
  saveLocalProfile();

  // If authenticated, also persist profile to Firestore (merge)
  try {
    final uid = FirebaseService.instance.currentUser?.uid;
    if (uid != null) {
      final profileMap = {
        'fullName': localProfile.value.fullName,
        'email': localProfile.value.email,
        'role': localProfile.value.role,
        'university': localProfile.value.university,
        'faculty': localProfile.value.faculty,
        'degree': localProfile.value.degree,
        'academicYear': localProfile.value.academicYear,
        'intake': localProfile.value.intake,
        'photoPath': localProfile.value.photoPath,
        'organizationName': localProfile.value.organizationName,
        'organizationLogoPath': localProfile.value.organizationLogoPath,
        'contactInfo': localProfile.value.contactInfo,
        'eventReminders': localProfile.value.eventReminders,
        'trendingEvents': localProfile.value.trendingEvents,
        'locationAccess': localProfile.value.locationAccess,
        'interests': localProfile.value.interests,
      };
      FirebaseService.instance.setUserProfile(uid, profileMap);
    }
  } catch (_) {}
}

class GatherUniLogo extends StatelessWidget {
  const GatherUniLogo({super.key, this.size = 72, this.dark = true});

  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .08),
      decoration: BoxDecoration(
        color: dark ? Colors.white : Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(size * .18),
        border: Border.all(color: Colors.white.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? .08 : .14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/gatheruni_logo.png',
        fit: BoxFit.contain,
        semanticLabel: 'GATHERUNI logo',
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.maxLines = 1,
  });

  final String label;
  final IconData icon;
  final bool obscure;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.mutedText, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.secondaryGreen, size: 20),
      ),
    );
  }
}

class AuthSwitch extends StatelessWidget {
  const AuthSwitch({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text('$text ', style: Theme.of(context).textTheme.bodyMedium),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.softBlue),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}

class SocialSignInRow extends StatelessWidget {
  const SocialSignInRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: AppColors.inputBorder.withOpacity(.45)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Sign in with',
                style: TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
            ),
            Expanded(
              child: Divider(color: AppColors.inputBorder.withOpacity(.45)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconSocialButton(asset: 'assets/icons/facebook.svg'),
            const SizedBox(width: 14),
            _IconSocialButton(asset: 'assets/icons/instagram.svg'),
            const SizedBox(width: 14),
            _IconSocialButton(asset: 'assets/icons/google.svg'),
          ],
        ),
      ],
    );
  }
}

class _IconSocialButton extends StatelessWidget {
  const _IconSocialButton({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.softBlue),
      ),
      child: SvgPicture.asset(
        asset,
        width: 20,
        height: 20,
        fit: BoxFit.contain,
      ),
    );
  }
}

class AuthBlob extends StatelessWidget {
  const AuthBlob({super.key, required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }
}

class AuthBubble extends StatelessWidget {
  const AuthBubble({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.accentYellow],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }
}

class AbstractAuthArt extends StatelessWidget {
  const AbstractAuthArt({super.key, this.compact = true});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondaryGreen, AppColors.lightBlue],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: compact ? -52 : -46,
            top: compact ? -36 : -18,
            child: const AuthBlob(
              size: 170,
              colors: [AppColors.primaryBlue, AppColors.secondaryGreen],
            ),
          ),
          Positioned(
            right: compact ? -44 : -50,
            top: compact ? -16 : 8,
            child: const AuthBlob(
              size: 190,
              colors: [Colors.white, AppColors.lightBlue],
            ),
          ),
          Positioned(
            right: compact ? 48 : 24,
            top: compact ? 118 : 78,
            child: const AuthBubble(size: 68),
          ),
          Positioned(
            left: compact ? 18 : 34,
            bottom: compact ? 20 : 84,
            child: AuthBlob(
              size: compact ? 150 : 210,
              colors: const [AppColors.accentYellow, AppColors.primaryBlue],
            ),
          ),
          Positioned(
            right: compact ? 26 : 42,
            bottom: compact ? 36 : 58,
            child: AuthBubble(size: compact ? 34 : 72),
          ),
        ],
      ),
    );
  }
}

// Event model and sample events (shared across screens)
class Event {
  const Event({
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.description,
    required this.colors,
    required this.bookings,
    this.imageUrl,
    this.id = '',
    this.isDraft = false,
    this.organizer,
  });

  final String id;
  final String title;
  final String category;
  final String date;
  final String time;
  final String location;
  final double price;
  final String description;
  final List<Color> colors;
  final int bookings;
  final String? imageUrl;
  final bool isDraft;
  final String? organizer;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date,
      'time': time,
      'location': location,
      'price': price,
      'description': description,
      'bookings': bookings,
      'imageUrl': imageUrl,
      'isDraft': isDraft,
      'organizer': organizer,
    };
  }

  factory Event.fromMap(Map<String, dynamic> m) {
    return Event(
      id: (m['id'] ?? '') as String,
      title: (m['title'] ?? '') as String,
      category: (m['category'] ?? '') as String,
      date: (m['date'] ?? '') as String,
      time: (m['time'] ?? '') as String,
      location: (m['location'] ?? '') as String,
      price: (m['price'] ?? 0) is int
          ? (m['price'] as int).toDouble()
          : (m['price'] ?? 0.0) as double,
      description: (m['description'] ?? '') as String,
      colors: [AppColors.primaryBlue, AppColors.lightBlue],
      bookings: (m['bookings'] ?? 0) as int,
      imageUrl: m['imageUrl'] as String?,
      isDraft: m['isDraft'] as bool? ?? false,
      organizer: m['organizer'] as String?,
    );
  }
}

const sampleEvents = [
  Event(
    title: 'AI Research Expo',
    category: 'Tech',
    date: 'May 12, 2026',
    time: '10:00 AM',
    location: 'Innovation Hall',
    price: 12,
    description:
        'Explore student-led AI projects, research posters, live demos, and a panel on responsible innovation for universities.',
    colors: [AppColors.primaryBlue, AppColors.lightBlue],
    bookings: 148,
    imageUrl:
        'https://images.unsplash.com/photo-1545235617-0c1a3d6b0a63?auto=format&fit=crop&w=800&q=60',
  ),
  Event(
    title: 'Campus Arts Night',
    category: 'Arts',
    date: 'May 18, 2026',
    time: '6:30 PM',
    location: 'Open Air Theater',
    price: 8,
    description:
        'A relaxed evening of live student bands, acoustic sets, food stalls, and community performances under the lights.',
    colors: [AppColors.secondaryGreen, AppColors.primaryBlue],
    bookings: 236,
    imageUrl:
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=800&q=60',
  ),
  Event(
    title: 'Interfaculty Finals',
    category: 'Sports',
    date: 'May 24, 2026',
    time: '3:00 PM',
    location: 'University Stadium',
    price: 5,
    description:
        'Cheer for the final match of the interfaculty tournament with live scores, team booths, and supporter zones.',
    colors: [AppColors.accentYellow, AppColors.secondaryGreen],
    bookings: 312,
    imageUrl:
        'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=800&q=60',
  ),
];

// User-created events (organizer mode)
final userEvents = ValueNotifier<List<Event>>(List<Event>.from(sampleEvents));

const _userEventsKey = 'userEvents.v1';

Future<void> loadUserEvents() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList(_userEventsKey) ?? <String>[];
  try {
    final parsed = raw
        .map((s) => Map<String, dynamic>.from(Uri.splitQueryString(s)))
        .map((m) => Event.fromMap(m))
        .toList();
    userEvents.value = [...sampleEvents, ...parsed];
  } catch (_) {
    userEvents.value = List<Event>.from(sampleEvents);
  }
}

Future<void> saveUserEvents() async {
  final prefs = await SharedPreferences.getInstance();
  final strings = userEvents.value
      .where((e) => e.id.isNotEmpty)
      .map((e) => e.toMap().map((k, v) => MapEntry(k, v?.toString() ?? '')))
      .map((m) => Uri(queryParameters: m).query)
      .toList();
  await prefs.setStringList(_userEventsKey, strings);
}

bool isEventOwnedByCurrentUser(Event e) {
  final uid = FirebaseService.instance.currentUser?.uid;
  final organizerName = localProfile.value.organizationName.isEmpty
      ? localProfile.value.fullName
      : localProfile.value.organizationName;

  if (uid != null) {
    if ((e.organizer ?? '') == uid) return true;
    // also allow matching by display name/organization for locally-created events
    if ((e.organizer ?? '') == organizerName) return true;
    return false;
  }

  // not signed in: allow if organizer matches local profile name
  return (e.organizer ?? '') == organizerName;
}

Future<void> addUserEvent(Event e) async {
  final next = List<Event>.from(userEvents.value);

  // If signed in, create in Firestore and use generated id
  final uid = FirebaseService.instance.currentUser?.uid;
  if (uid != null) {
    try {
      final data = e.toMap();
      data['organizerId'] = uid;
      final ref = await FirebaseService.instance.createEvent(data);
      final created = Event(
        id: ref.id,
        title: e.title,
        category: e.category,
        date: e.date,
        time: e.time,
        location: e.location,
        price: e.price,
        description: e.description,
        colors: e.colors,
        bookings: e.bookings,
        imageUrl: e.imageUrl,
        isDraft: e.isDraft,
        organizer: uid,
      );
      next.insert(0, created);
      userEvents.value = next;
      await saveUserEvents();
      return;
    } catch (_) {
      // fallback to local-only
    }
  }

  next.insert(0, e);
  userEvents.value = next;
  await saveUserEvents();
}

Future<void> editUserEvent(String id, Event updated) async {
  // If signed in and event has an id, verify ownership then update Firestore
  final uid = FirebaseService.instance.currentUser?.uid;
  if (uid != null && updated.id.isNotEmpty) {
    // find existing local event to check organizer
    Event? existing;
    for (final ev in userEvents.value) {
      if (ev.id == id) {
        existing = ev;
        break;
      }
    }

    final localOrganizerName = localProfile.value.organizationName.isEmpty
        ? localProfile.value.fullName
        : localProfile.value.organizationName;

    if (existing != null) {
      final organizerField = existing.organizer ?? '';
      if (organizerField.isNotEmpty &&
          organizerField != uid &&
          organizerField != localOrganizerName) {
        throw Exception('Not authorized to edit this event');
      }
    }

    try {
      await FirebaseService.instance.updateEvent(updated.id, updated.toMap());
    } catch (_) {}
  }

  final next = userEvents.value.map((e) => e.id == id ? updated : e).toList();
  userEvents.value = next;
  await saveUserEvents();
}

Future<void> deleteUserEvent(String id) async {
  final uid = FirebaseService.instance.currentUser?.uid;

  // check ownership before remote delete
  Event? existing;
  for (final ev in userEvents.value) {
    if (ev.id == id) {
      existing = ev;
      break;
    }
  }

  final localOrganizerName = localProfile.value.organizationName.isEmpty
      ? localProfile.value.fullName
      : localProfile.value.organizationName;

  if (uid != null && id.isNotEmpty && existing != null) {
    final organizerField = existing.organizer ?? '';
    if (organizerField.isNotEmpty &&
        organizerField != uid &&
        organizerField != localOrganizerName) {
      throw Exception('Not authorized to delete this event');
    }

    try {
      await FirebaseService.instance.deleteEvent(id);
    } catch (_) {}
  }

  final next = userEvents.value.where((e) => e.id != id).toList();
  userEvents.value = next;
  await saveUserEvents();
}

class AuthHeroCard extends StatelessWidget {
  const AuthHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AbstractAuthArt(compact: false),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryBlue.withOpacity(.05),
                  AppColors.primaryBlue.withOpacity(.70),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter personal details to explore university events.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const GatherUniLogo(size: 92, dark: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthGradientScaffold extends StatelessWidget {
  const AuthGradientScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.background, AppColors.softBlue],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 315,
            child: AbstractAuthArt(),
          ),
          child,
        ],
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.children,
    this.showBack = false,
  });

  final String title;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthGradientScaffold(
        child: SafeArea(
          child: Stack(
            children: [
              if (showBack)
                Positioned(
                  top: 18,
                  left: 18,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.chevron_left, size: 18),
                    label: const Text('Back'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              const Positioned(
                top: 28,
                left: 0,
                right: 0,
                child: Center(child: GatherUniLogo(size: 120, dark: false)),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 430),
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(.10),
                          blurRadius: 34,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.primaryBlue),
                        ),
                        const SizedBox(height: 22),
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
