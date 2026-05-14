import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../../widgets/greeting_header.dart';
import '../../services/organizer_service.dart';
import '../../../screens/admin/organizer_review_screen.dart';
import '../events/create_event_screen.dart';
import '../events/event_list_screen.dart';
import '../organizer/organizer_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _listFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.35)));

    _listFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
    );

    _ctrl.forward();
    // Listen for role changes to detect when the user becomes an organizer
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((snap) async {
        final role = snap.data()?['role'] as String?;
        if (role == 'organizer' && mounted) {
          if (!_promptedBecomeOrganizer) {
            _promptedBecomeOrganizer = true;
            // Auto-navigate: if profile exists, go to CreateEventScreen; otherwise go to OrganizerProfileScreen
            bool hasProfile = false;
            try {
              final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
              final data = userDoc.data();
              if (data != null && (data['displayName'] != null || data['organizationName'] != null)) {
                hasProfile = true;
              }
            } catch (_) {}

            if (!hasProfile && mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrganizerProfileScreen()),
              );
            } else if (mounted) {
              String? initialTitle;
              try {
                final q = await FirebaseFirestore.instance
                    .collection('organizer_requests')
                    .where('uid', isEqualTo: uid)
                    .where('status', isEqualTo: 'approved')
                    .orderBy('submittedAt', descending: true)
                    .limit(1)
                    .get();
                if (q.docs.isNotEmpty) initialTitle = q.docs.first.data()['organizationName'] as String?;
              } catch (_) {}
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateEventScreen(initialTitle: initialTitle)),
              );
            }
          }
        }
      });
    }


  bool _promptedBecomeOrganizer = false;
  
  Future<void> _setUserRole(String role) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not signed in')));
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({'role': role}, SetOptions(merge: true));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role set to $role')));
      if (role == 'organizer' && mounted) {
        _promptedBecomeOrganizer = false;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrganizerProfileScreen()),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _animatedCard(int index) {
    final start = 0.35 + index * 0.08;
    final end = (start + 0.45).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(anim),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 56,
                height: 56,
                color: Colors.blue[(100 * ((index % 8) + 1)).clamp(100, 800)],
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            title: Text('Event ${index + 1}'),
            subtitle: const Text('Short event description goes here'),
            trailing: Transform.rotate(
              angle: (math.pi / 180) * (index.isEven ? -6 : 6),
              child: Icon(Icons.event, color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GatherUni'),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Dev: Role helper',
              onPressed: () async {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Dev: Role Helper'),
                    content: const Text('Set or revert the current user role for testing.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await _setUserRole('user');
                        },
                        child: const Text('Revert to user'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await _setUserRole('organizer');
                        },
                        child: const Text('Set organizer'),
                      ),
                    ],
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Events',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventListScreen()),
              );
            },
          ),
          FutureBuilder<bool>(
            future: OrganizerService.isAdmin(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done)
                return const SizedBox.shrink();
              if (snap.data != true) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                tooltip: 'Admin panel',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrganizerReviewScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: const GreetingHeader(),
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _listFade,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemCount: 6,
                itemBuilder: (context, i) => _animatedCard(i),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: OrganizerService.isOrganizer(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const SizedBox.shrink();
          if (snap.data != true) return const SizedBox.shrink();
          return FloatingActionButton(
            child: const Icon(Icons.add),
            tooltip: 'Create Event',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateEventScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
