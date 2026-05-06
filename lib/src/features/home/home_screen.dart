import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../widgets/greeting_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _headerFade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
  );

  late final Animation<Offset> _headerSlide = Tween<Offset>(
    begin: const Offset(0, -0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.35)));

  late final Animation<double> _listFade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
  );

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
      appBar: AppBar(title: const Text('GatherUni'), actions: const []),
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
    );
  }
}
