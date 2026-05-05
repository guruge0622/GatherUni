import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';
import 'event_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryCtrl = TextEditingController();
  String _query = '';
  String _category = 'All';

  List<Event> get _results {
    return sampleEvents.where((event) {
      final matchesQuery =
          _query.isEmpty ||
          event.title.toLowerCase().contains(_query.toLowerCase()) ||
          event.location.toLowerCase().contains(_query.toLowerCase()) ||
          event.category.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory = _category == 'All' || event.category == _category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...interests];

    return Scaffold(
      backgroundColor: GatherColors.background,
      appBar: AppBar(title: const Text('Search')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          TextField(
            controller: _queryCtrl,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Search events, clubs, venues',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _queryCtrl.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category == _category;
                return ChoiceChip(
                  selected: selected,
                  label: Text(category),
                  selectedColor: GatherColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : GatherColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(() => _category = category),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: categories.length,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '${_results.length} results',
            style: const TextStyle(
              color: GatherColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ..._results.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EventResultTile(event: event),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventResultTile extends StatelessWidget {
  const _EventResultTile({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6ECF6)),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: event.colors),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.event_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: GatherColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${event.date} - ${event.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: GatherColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
