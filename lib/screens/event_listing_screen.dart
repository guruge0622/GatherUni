import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../src/theme/design_system.dart';
import '../src/shared.dart';
import 'event_detail_screen.dart';
import '../src/components/event_card.dart';

class EventListingScreen extends StatefulWidget {
  final bool showOnlyBookmarked;

  const EventListingScreen({super.key, this.showOnlyBookmarked = false});

  @override
  State<EventListingScreen> createState() => _EventListingScreenState();
}

class _EventListingScreenState extends State<EventListingScreen> {
  final categories = ['All', 'Music', 'Tech', 'Sports', 'Arts'];
  String selected = 'All';
  final Set<String> _bookmarks = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _loadSelectedCategory();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bookmarkedEvents') ?? [];
    setState(() => _bookmarks.addAll(list));
  }

  Future<void> _toggleBookmark(String key) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarks.contains(key)) {
        _bookmarks.remove(key);
      } else {
        _bookmarks.add(key);
      }
      prefs.setStringList('bookmarkedEvents', _bookmarks.toList());
    });
  }

  Future<void> _loadSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final cat = prefs.getString('selectedCategory') ?? 'All';
    setState(() => selected = cat);
  }

  Future<void> _setSelectedCategory(String cat) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => selected = cat);
    await prefs.setString('selectedCategory', cat);
  }

  @override
  Widget build(BuildContext context) {
    // combine sample events with published user events
    final published = userEvents.value.where((e) => !e.isDraft).toList();
    final combined = [...published, ...sampleEvents];

    List<Event> items = combined.where((e) {
      if (selected == 'All') return true;
      return e.category.toLowerCase() == selected.toLowerCase();
    }).toList();

    if (widget.showOnlyBookmarked) {
      items = items.where((e) => _bookmarks.contains(e.title)).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Container(
        color: GatherColors.background,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((c) {
                  final active = c == selected;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: active,
                      onSelected: (_) => _setSelectedCategory(c),
                      selectedColor: GatherColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: active ? Colors.white : GatherColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final e = items[index];
                  final key = e.title;
                  return EventCard(
                    imageUrl: e.imageUrl,
                    title: e.title,
                    date: e.date,
                    location: e.location,
                    price: e.price,
                    colors: e.colors,
                    compact: true,
                    isBookmarked: _bookmarks.contains(key),
                    onBookmarkToggle: () => _toggleBookmark(key),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(event: e),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
