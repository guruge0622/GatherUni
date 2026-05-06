import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'src/backend/firebase_service.dart';
import 'firebase_options.dart';
// Firebase backend
import 'src/shared.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'src/theme/design_system.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/onboarding_profile_screen.dart';
import 'screens/interest_selection_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/search_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/modern_home_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/recommended_events_screen.dart';
import 'screens/event_listing_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/ai_chatbot_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/create_event_screen.dart';
import 'screens/event_preview_screen.dart';
import 'screens/organizer_dashboard_screen.dart';

// alias sample events from shared
const events = sampleEvents;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // start with local cache
  await loadLocalProfile();
  await loadUserEvents();

  // Listen for auth changes and sync Firestore data
  StreamSubscription? eventsSub;
  FirebaseService.instance.authStateChanges().listen((user) async {
    if (user != null) {
      try {
        final profileDoc = await FirebaseService.instance.getUserProfile(
          user.uid,
        );
        if (profileDoc.exists && profileDoc.data() != null) {
          final data = profileDoc.data()!;
          updateLocalProfile(
            fullName: data['fullName'] as String?,
            email: data['email'] as String?,
            role: data['role'] as String?,
            university: data['university'] as String?,
            faculty: data['faculty'] as String?,
            degree: data['degree'] as String?,
            academicYear: data['academicYear'] as String?,
            intake: data['intake'] as String?,
            photoPath: data['photoPath'] as String?,
            organizationName: data['organizationName'] as String?,
            organizationLogoPath: data['organizationLogoPath'] as String?,
            contactInfo: data['contactInfo'] as String?,
            eventReminders: data['eventReminders'] as bool?,
            trendingEvents: data['trendingEvents'] as bool?,
            locationAccess: data['locationAccess'] as bool?,
            interests: (data['interests'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList(),
          );
        }

        // subscribe to organizer events
        await eventsSub?.cancel();
        eventsSub = FirebaseService.instance.streamUserEvents(user.uid).listen((
          snap,
        ) {
          final events = snap.docs.map((d) {
            final data = Map<String, dynamic>.from(d.data());
            data['id'] = d.id;
            if (data['organizerId'] != null) {
              data['organizer'] = data['organizerId'];
            }
            return Event.fromMap(data);
          }).toList();
          userEvents.value = events;
        });
      } catch (_) {
        // on error, keep local cache
      }
    } else {
      // signed out: cancel subscriptions and reload local cache
      await eventsSub?.cancel();
      await loadLocalProfile();
      await loadUserEvents();
    }
  });

  runApp(const GatherUniApp());
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  late final pages = [
    const ModernHomeScreen(),
    const SearchScreen(),
    const CalendarScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        indicatorColor: GatherColors.primary.withValues(alpha: .12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ChatScreen())),
        tooltip: 'Chat',
        backgroundColor: const Color(0xFF7B61FF),
        child: const Icon(Icons.smart_toy),
      ),
    );
  }
}

class GatherUniApp extends StatelessWidget {
  const GatherUniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GATHERUNI',
      theme: GatherTheme.light(),
      home: const SplashScreen(),
      routes: {
        '/main': (_) => const MainShell(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/payment': (_) => const PaymentScreen(),
        '/booking-confirmation': (_) => const BookingConfirmationScreen(),
        '/calendar': (_) => const CalendarScreen(),
        '/search': (_) => const SearchScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/recommended': (_) => const RecommendedEventsScreen(),
        '/events': (_) => const EventListingScreen(),
        '/privacy': (_) => const PrivacyPolicyScreen(),
        '/terms': (_) => const TermsScreen(),
        '/support': (_) => const HelpSupportScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/feedback': (_) => const FeedbackScreen(),
        '/tickets': (_) => const MyTicketsScreen(),
        '/ai-assistant': (_) => const AIChatbotScreen(),
        '/onboarding': (_) => const OnboardingProfileScreen(),
        '/interests': (_) => const InterestSelectionScreen(),
        '/profile/edit': (_) => const EditProfileScreen(),
        '/organizer/create': (_) => const CreateEventScreen(),
        '/organizer/preview': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;
          if (args is Event) return EventPreviewScreen(event: args);
          return Scaffold(
            appBar: AppBar(title: const Text('Event Preview')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No event to preview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please create an event first or open an existing draft.',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.of(
                        ctx,
                      ).pushReplacementNamed('/organizer/create'),
                      child: const Text('Create Event'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        '/organizer/dashboard': (_) => const OrganizerDashboardScreen(),
      },
    );
  }
}

class MyApp extends GatherUniApp {
  const MyApp({super.key});
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryGreen,
        tertiary: AppColors.accentYellow,
        surface: AppColors.card,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.text,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          color: AppColors.text,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.text, fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(
          color: AppColors.mutedText,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.text,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

// ProfileScreen removed: using modular `ProfileScreen` in `lib/screens/profile_screen.dart`

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
                          color: AppColors.primaryBlue.withValues(alpha: .10),
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
                  AppColors.primaryBlue.withValues(alpha: .05),
                  AppColors.primaryBlue.withValues(alpha: .70),
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
            color: AppColors.primaryBlue.withValues(alpha: .20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
              child: Divider(
                color: AppColors.inputBorder.withValues(alpha: .45),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Sign in with',
                style: TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.inputBorder.withValues(alpha: .45),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialButton(
              icon: SvgPicture.asset(
                'assets/icons/facebook.svg',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              onTap: () {},
            ),
            const SizedBox(width: 14),
            SocialButton(
              icon: SvgPicture.asset(
                'assets/icons/instagram.svg',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              onTap: () {},
            ),
            const SizedBox(width: 14),
            SocialButton(
              icon: SvgPicture.asset(
                'assets/icons/google.svg',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, this.icon, this.label, this.onTap});

  final Widget? icon;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.softBlue),
        ),
        child: icon != null
            ? IconTheme(data: const IconThemeData(size: 20), child: icon!)
            : Text(
                label ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.withBack = true,
    this.action,
  });

  final String title;
  final Widget child;
  final bool withBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: withBack,
        title: Text(title),
        actions: action == null ? null : [action!, const SizedBox(width: 10)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: child,
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.gradient});

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? Colors.white : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
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
        color: dark ? Colors.white : Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(size * .18),
        border: Border.all(color: Colors.white.withValues(alpha: .35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .08 : .14),
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

class SmartSearchBar extends StatelessWidget {
  const SmartSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Smart search events, clubs, venues...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.secondaryGreen,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'AI',
                  style: TextStyle(
                    color: AppColors.secondaryGreen,
                    fontWeight: FontWeight.w800,
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

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        trailing ?? const SizedBox(),
      ],
    );
  }
}

class RecommendedEventCard extends StatelessWidget {
  const RecommendedEventCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: SizedBox(
        width: 254,
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              EventImage(event: event, height: 100),
              const SizedBox(height: 12),
              CategoryPill(label: event.category),
              const SizedBox(height: 8),
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              InfoRow(
                icon: Icons.calendar_today_outlined,
                text: event.date,
                compact: true,
              ),
              const SizedBox(height: 4),
              InfoRow(
                icon: Icons.location_on_outlined,
                text: event.location,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventListTile extends StatelessWidget {
  const EventListTile({super.key, required this.event, this.navigate = true});

  final Event event;
  final bool navigate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: navigate
          ? () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: event),
              ),
            )
          : null,
      child: AppCard(
        child: Row(
          children: [
            EventImage(event: event, width: 92, height: 92),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 7),
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: event.date,
                    compact: true,
                  ),
                  const SizedBox(height: 4),
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    text: event.location,
                    compact: true,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.price == 0
                        ? 'Free'
                        : '\$${event.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.secondaryGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventImage extends StatelessWidget {
  const EventImage({
    super.key,
    required this.event,
    this.width = double.infinity,
    this.height = 120,
    this.borderRadius,
    this.iconSize = 42,
  });

  final Event event;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: event.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Icon(
              Icons.circle,
              size: 86,
              color: Colors.white.withValues(alpha: .14),
            ),
          ),
          Center(
            child: Icon(
              _interestIcon(event.category),
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    this.color = AppColors.secondaryGreen,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.compact = false,
  });

  final IconData icon;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.mutedText, size: compact ? 15 : 18),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: compact ? 12 : 14),
          ),
        ),
      ],
    );
  }
}

class PricePanel extends StatelessWidget {
  const PricePanel({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondaryGreen.withValues(alpha: .13),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: AppColors.secondaryGreen,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Ticket price',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            event.price == 0 ? 'Free' : '\$${event.price.toStringAsFixed(0)}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.secondaryGreen),
          ),
        ],
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  const QuantityButton({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: onTap == null
            ? Colors.grey.shade200
            : AppColors.primaryBlue,
        foregroundColor: onTap == null ? AppColors.mutedText : Colors.white,
        fixedSize: const Size(48, 48),
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
      return Icons.event;
  }
}
