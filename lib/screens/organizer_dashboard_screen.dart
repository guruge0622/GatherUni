import 'package:flutter/material.dart';
import '../src/shared.dart';
// design_system not used here

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() =>
      _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final organizerName = localProfile.value.organizationName.isEmpty
        ? localProfile.value.fullName
        : localProfile.value.organizationName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Drafts'),
            Tab(text: 'Published'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/organizer/create'),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          ValueListenableBuilder<List<Event>>(
            valueListenable: userEvents,
            builder: (c, list, _) {
              final drafts = list
                  .where(
                    (e) => e.isDraft && (e.organizer ?? '') == organizerName,
                  )
                  .toList();
              if (drafts.isEmpty) {
                return const Center(child: Text('No drafts'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (ctx, i) => _eventTile(drafts[i]),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemCount: drafts.length,
              );
            },
          ),
          ValueListenableBuilder<List<Event>>(
            valueListenable: userEvents,
            builder: (c, list, _) {
              final published = list
                  .where(
                    (e) => !e.isDraft && (e.organizer ?? '') == organizerName,
                  )
                  .toList();
              if (published.isEmpty) {
                return const Center(child: Text('No published events'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (ctx, i) => _eventTile(published[i]),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemCount: published.length,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _eventTile(Event e) {
    return Card(
      child: ListTile(
        title: Text(e.title),
        subtitle: Text('${e.date} • ${e.time}'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            final nav = Navigator.of(context);
            final scaffold = ScaffoldMessenger.of(context);
            if (v == 'edit') {
              nav.pushNamed('/organizer/create', arguments: e);
            } else if (v == 'delete') {
              try {
                UIFeedback.showLoading(context, message: 'Deleting...');
                await deleteUserEvent(e.id);
                UIFeedback.hideLoading(context);
                UIFeedback.showSnack(context, 'Deleted');
              } catch (err) {
                UIFeedback.hideLoading(context);
                UIFeedback.showSnack(context, 'Delete failed: ${err.toString()}', success: false);
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
