import 'package:flutter/material.dart';
import '../src/shared.dart';
import 'event_detail_screen.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<_CategoryItem> _categories = const [
    _CategoryItem('All', Icons.apps_rounded, Color(0xFF395886)),
    _CategoryItem('Academics', Icons.school_rounded, Color(0xFF395886)),
    _CategoryItem('Arts', Icons.palette_rounded, Color(0xFF9A5D2E)),
    _CategoryItem('Cultural', Icons.diversity_3_rounded, Color(0xFF2F7D6D)),
    _CategoryItem('Sports', Icons.sports_soccer_rounded, Color(0xFF4B7F2C)),
    _CategoryItem('Tech', Icons.memory_rounded, Color(0xFF5C63A7)),
  ];
  int _selectedCategory = 0;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FA),
      body: SafeArea(
        child: ValueListenableBuilder<List<Event>>(
          valueListenable: userEvents,
          builder: (context, userList, _) {
            final published = userList.where((e) => !e.isDraft).toList();
            final combined = [...published, ...sampleEvents];
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Good Morning",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            "Nishadi 👋",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF395886),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.notifications_none),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              height: 8,
                              width: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔍 SEARCH BAR (improved)
                  _buildSearchBar(),

                  const SizedBox(height: 20),

                  // 🎨 CATEGORIES
                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 0),
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final isActive = _selectedCategory == index;
                        final category = _categories[index];
                        return _CategoryChip(
                          category: category,
                          selected: isActive,
                          onTap: () =>
                              setState(() => _selectedCategory = index),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  _sectionHeader(
                    "Recommended Events",
                    "Based on your interests",
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 236,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: combined.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return _recommendedEventCard(combined[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📈 TRENDING
                  sectionTitle("Trending Events"),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 220,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [trendingCard(), trendingCard()],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📅 UPCOMING
                  sectionTitle("Upcoming Events"),

                  const SizedBox(height: 12),

                  for (final e in combined.take(4))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(event: e),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: e.colors),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                onPressed: () {},
                                icon: const Icon(Icons.ios_share_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 🔹 CATEGORY CHIP
  // (old categoryChip removed; chips are rendered as ChoiceChip in the list)

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isSearchFocused
              ? const Color(0xFF395886)
              : const Color(0xFFD5DEEF),
          width: _isSearchFocused ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF395886,
            ).withAlpha(((_isSearchFocused ? 0.16 : 0.08) * 255).round()),
            blurRadius: _isSearchFocused ? 24 : 18,
            offset: Offset(0, _isSearchFocused ? 12 : 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFD5DEEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF395886),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                return TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  cursorColor: const Color(0xFF395886),
                  style: const TextStyle(
                    color: Color(0xFF171D35),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search events, clubs, venues',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: const Color(0xFF6B7280),
                            onPressed: _searchController.clear,
                          ),
                    suffixIconConstraints: const BoxConstraints(
                      minHeight: 36,
                      minWidth: 36,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (v) {
                    Navigator.of(context).pushNamed('/search');
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/search');
            },
            borderRadius: BorderRadius.circular(13),
            child: Ink(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF395886),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF171D35),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF395886),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
          child: const Text("See all"),
        ),
      ],
    );
  }

  Widget _recommendedEventCard(Event event) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6ECF6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF395886).withValues(alpha: .09),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 106,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: event.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -18,
                    top: -20,
                    child: Icon(
                      Icons.circle,
                      size: 92,
                      color: Colors.white.withValues(alpha: .14),
                    ),
                  ),
                  Center(
                    child: Icon(
                      _eventCategoryIcon(event.category),
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MiniCategoryPill(category: event.category),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF395886),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF171D35),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _CompactInfoRow(
                    icon: Icons.calendar_today_rounded,
                    text: event.date,
                  ),
                  const SizedBox(height: 5),
                  _CompactInfoRow(
                    icon: Icons.location_on_rounded,
                    text: event.location,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 TRENDING CARD
  Widget trendingCard() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFD5DEEF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: const Center(child: Icon(Icons.image)),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Arts Showcase",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("June 10 • Galle", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 UPCOMING LIST CARD
  Widget eventListCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFD5DEEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Startup Pitch",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("May 25 • Colombo", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  // 🔹 TITLE
  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

IconData _eventCategoryIcon(String category) {
  switch (category) {
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
      return Icons.event_rounded;
  }
}

class _MiniCategoryPill extends StatelessWidget {
  const _MiniCategoryPill({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD5DEEF).withValues(alpha: .62),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: Color(0xFF395886),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CompactInfoRow extends StatelessWidget {
  const _CompactInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF638ECB), size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryItem {
  const _CategoryItem(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _CategoryItem category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : const Color(0xFF24364F);
    final background = selected ? category.color : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? category.color : const Color(0xFFD5DEEF),
            ),
            boxShadow: [
              BoxShadow(
                color: category.color.withValues(alpha: selected ? .20 : .07),
                blurRadius: selected ? 18 : 10,
                offset: Offset(0, selected ? 8 : 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: .18)
                      : category.color.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  category.icon,
                  size: 16,
                  color: selected ? Colors.white : category.color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category.label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
