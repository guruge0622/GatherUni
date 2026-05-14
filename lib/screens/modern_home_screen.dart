import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../src/shared.dart';
import '../src/widgets/greeting_header.dart';
import 'event_detail_screen.dart';
import 'chatbot_v2_screen.dart';
import '../services/chat_service.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final PageController _featuredCtrl = PageController(viewportFraction: 0.92);
  Timer? _featuredTimer;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  bool _showHint = true;
  Timer? _hintTimer;

  String? _selectedCategory;
  final Set<String> _savedEventIds = {};

  static const _savedKey = 'savedEvents.v1';

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _startFeaturedAutoScroll();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.98, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_savedKey) ?? <String>[];
    if (mounted) setState(() => _savedEventIds.addAll(list));
  }

  Future<void> _persistSaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedKey, _savedEventIds.toList());
  }

  void _toggleSave(Event e) {
    setState(() {
      if (_savedEventIds.contains(e.id)) {
        _savedEventIds.remove(e.id);
      } else {
        _savedEventIds.add(e.id);
      }
    });
    _persistSaved();
  }

  void _shareEvent(Event e) {
    final txt = '${e.title} — ${e.date} at ${e.location}';
    Share.share(txt);
  }

  void _startFeaturedAutoScroll() {
    _featuredTimer?.cancel();
    _featuredTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_featuredCtrl.hasClients) return;
      final next = (_featuredCtrl.page?.round() ?? 0) + 1;
      if (next >= _featured.length) {
        _featuredCtrl.animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _featuredCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _featuredTimer?.cancel();
    _pulseController.dispose();
    _hintTimer?.cancel();
    _searchController.dispose();
    _featuredCtrl.dispose();
    super.dispose();
  }

  List<Event> get _combined => [...sampleEvents, ...userEvents.value];

  List<Event> get _featured =>
      List<Event>.from(_combined)
        ..sort((a, b) => b.bookings.compareTo(a.bookings));

  List<Category> get _categories => [
    const Category(name: 'All', color: AppColors.primaryBlue),
    ...interests.map((i) => Category(name: i, color: AppColors.primaryBlue)),
  ];

  List<Event> get _recommended {
    final base = _combined;
    if (_selectedCategory == null || _selectedCategory == 'All') return base;
    return base.where((e) => e.category == _selectedCategory).toList();
  }

  List<Event> get _upcoming {
    final df = DateFormat('MMMM d, y');
    final now = DateTime.now();
    final base = _combined.where((e) {
      try {
        final dt = df.parse(e.date);
        return !dt.isBefore(now);
      } catch (_) {
        return true;
      }
    }).toList();
    if (_selectedCategory != null && _selectedCategory != 'All') {
      return base.where((e) => e.category == _selectedCategory).toList()
        ..sort((a, b) {
          try {
            final da = df.parse(a.date);
            final db = df.parse(b.date);
            return da.compareTo(db);
          } catch (_) {
            return 0;
          }
        });
    }
    base.sort((a, b) {
      try {
        final da = df.parse(a.date);
        final db = df.parse(b.date);
        return da.compareTo(db);
      } catch (_) {
        return 0;
      }
    });
    return base;
  }

  Widget _featuredCard(Event e) {
    final saved = _savedEventIds.contains(e.id);
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => EventDetailScreen(event: e))),
      child: Container(
        margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: e.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(e.imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          gradient: e.imageUrl == null
              ? LinearGradient(colors: e.colors)
              : null,
        ),
        child: Stack(
          children: [
            if (e.imageUrl != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.28),
                  ),
                ),
              )
            else
              Positioned.fill(child: Container()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    e.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${e.date} • ${e.time}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _shareEvent(e),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.share, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _toggleSave(e),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: saved ? Colors.white : Colors.white24,
                      child: Icon(
                        saved ? Icons.favorite : Icons.favorite_border,
                        color: saved ? AppColors.primaryBlue : Colors.white,
                        size: 18,
                      ),
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

  Widget _recommendedCard(Event e) {
    final saved = _savedEventIds.contains(e.id);
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: e.imageUrl != null
                ? Image.network(
                    e.imageUrl!,
                    width: double.infinity,
                    height: 110,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: e.colors),
                    ),
                    child: const Center(
                      child: Icon(Icons.event, color: Colors.white, size: 48),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  '${e.date} • ${e.time}',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _shareEvent(e),
                      icon: const Icon(Icons.ios_share_rounded),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _toggleSave(e),
                      icon: Icon(
                        saved ? Icons.favorite : Icons.favorite_border,
                        color: saved ? AppColors.primaryBlue : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GreetingHeader(),
                    const SizedBox(height: 14),

                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration.collapsed(
                                hintText: 'Search events, clubs, venues',
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) =>
                                  Navigator.of(context).pushNamed('/search'),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/search'),
                            icon: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Categories
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final cat = _categories[idx];
                          final selected =
                              (_selectedCategory ?? 'All') == cat.name;
                          return ChoiceChip(
                            label: Text(cat.name),
                            selected: selected,
                            onSelected: (_) => setState(
                              () => _selectedCategory = cat.name == 'All'
                                  ? null
                                  : cat.name,
                            ),
                            selectedColor: cat.color.withOpacity(.18),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Trending
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Trending',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/events'),
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: PageView.builder(
                        controller: _featuredCtrl,
                        itemCount: _featured.length,
                        itemBuilder: (context, i) =>
                            _featuredCard(_featured[i]),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recommended Events
                    if (_recommended.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recommended Events',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 236,
                        child: ValueListenableBuilder<List<Event>>(
                          valueListenable: userEvents,
                          builder: (context, value, child) {
                            final list = _recommended;
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: list.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, i) =>
                                  _recommendedCard(list[i]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Upcoming Events (compact preview)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/upcoming'),
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_upcoming.isNotEmpty) ...[
                      Column(
                        children: [
                          for (
                            var i = 0;
                            i < (_upcoming.length > 2 ? 2 : _upcoming.length);
                            i++
                          )
                            Builder(
                              builder: (context) {
                                final e = _upcoming[i];
                                final saved = _savedEventIds.contains(e.id);
                                return GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EventDetailScreen(event: e),
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE6ECF6),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: e.imageUrl != null
                                              ? Image.network(
                                                  e.imageUrl!,
                                                  width: 64,
                                                  height: 64,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 64,
                                                  height: 64,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: e.colors,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${e.date} • ${e.time}',
                                                style: const TextStyle(
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _shareEvent(e),
                                          icon: const Icon(
                                            Icons.ios_share_rounded,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _toggleSave(e),
                                          icon: Icon(
                                            saved
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: saved
                                                ? AppColors.primaryBlue
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Chatbot rounded-square button (bottom-right)
            Positioned(
              bottom: 80,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showHint)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text('Ask me about events 🤖'),
                      ),
                    ),

                  GestureDetector(
                    onTap: () {
                      setState(() => _showHint = false);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatbotV2Screen(chatService: ChatService()),
                        ),
                      );
                    },
                    child: ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B8CFF), Color(0xFF9C6BFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9C6BFF).withOpacity(0.36),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.smart_toy_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
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

class Category {
  const Category({required this.name, required this.color});
  final String name;
  final Color color;
}
