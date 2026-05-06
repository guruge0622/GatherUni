import 'package:flutter/material.dart';
import '../core/auth_guard.dart';
import '../../screens/login_screen.dart';
import '../../screens/create_event_screen.dart';
import '../../screens/event_preview_screen.dart';
import '../../screens/organizer_dashboard_screen.dart';
import '../../screens/interest_selection_screen.dart';
import '../../screens/profile_screen.dart';
import '../shared.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_flow.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingFlow());
      case '/home':
        return MaterialPageRoute(
          builder: (_) => AuthGate(child: const HomeScreen()),
        );
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => AuthGate(child: const ProfileScreen()),
        );
      case '/interests':
        return MaterialPageRoute(
          builder: (_) => const InterestSelectionScreen(),
        );
      case '/organizer':
      case '/organizer/dashboard':
        return MaterialPageRoute(
          builder: (_) => AuthGate(child: const OrganizerDashboardScreen()),
        );
      case '/organizer/create':
        return MaterialPageRoute(builder: (_) => const CreateEventScreen());
      case '/organizer/preview':
        final event = settings.arguments as Event?;
        if (event == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Preview')),
              body: const Center(child: Text('No event provided for preview')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => EventPreviewScreen(event: event),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Unknown')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
