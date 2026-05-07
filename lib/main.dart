import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'src/shared.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
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
import 'screens/edit_profile_screen.dart';
import 'screens/chatbot_v2_screen.dart';
import 'services/chat_service.dart';
import 'screens/create_event_screen.dart';
import 'screens/event_preview_screen.dart';
import 'screens/organizer_dashboard_screen.dart';

Future<void> main() async {
  // Run initialization inside the same zone as runApp to avoid zone mismatch warnings
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {
        // ignore: avoid_print
        print('.env not found; continuing');
      }

      // Load local caches used by the app
      await loadLocalProfile();
      await loadUserEvents();

      FlutterError.onError = (details) {
        Zone.current.handleUncaughtError(
          details.exception,
          details.stack ?? StackTrace.current,
        );
      };

      runApp(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const GatherUniApp(),
        ),
      );
    },
    (err, stack) {
      // ignore: avoid_print
      print('Uncaught error: $err');
      // ignore: avoid_print
      print(stack);
    },
  );
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
        indicatorColor: GatherColors.primary.withOpacity(.12),
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
    );
  }
}

class GatherUniApp extends StatelessWidget {
  const GatherUniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GATHERUNI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
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
        '/ai-assistant': (_) => ChatbotV2Screen(chatService: ChatService()),
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
