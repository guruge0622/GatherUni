import 'package:flutter/material.dart';
import 'package:my_app/src/models/organizer_request.dart';
import 'package:my_app/src/services/organizer_service.dart';

class OrganizerReviewScreen extends StatefulWidget {
  const OrganizerReviewScreen({Key? key}) : super(key: key);

  @override
  State<OrganizerReviewScreen> createState() => _OrganizerReviewScreenState();
}

class _OrganizerReviewScreenState extends State<OrganizerReviewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  String _statusForIndex(int i) {
    switch (i) {
      case 0:
        return 'submitted';
      case 1:
        return 'approved';
      case 2:
        return 'rejected';
      default:
        return 'submitted';
    }
  }

  Future<void> _confirmApprove(OrganizerRequest req) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve request'),
        content: Text('Approve ${req.organizationName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await OrganizerService.updateStatus(req.id, 'approved');
    }
  }

  Future<void> _rejectWithReason(OrganizerRequest req) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject ${req.organizationName}?'),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await OrganizerService.updateStatus(
        req.id,
        'rejected',
        rejectionReason: ctrl.text.trim().isEmpty ? null : ctrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OrganizerService.isAdmin(),
      builder: (context, snapAdmin) {
        if (snapAdmin.connectionState != ConnectionState.done)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        final isAdmin = snapAdmin.data == true;
        if (!isAdmin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Organizer Review')),
            body: const Center(child: Text('Access Denied')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Organizer Review'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by organization or email',
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(3, (i) {
                    final status = _statusForIndex(i);
                    return StreamBuilder<List<OrganizerRequest>>(
                      stream: OrganizerService.streamRequests(
                        status: status == 'submitted' ? 'submitted' : status,
                        query: _search.isEmpty ? null : _search,
                      ),
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.active)
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        if (snap.hasError)
                          return Center(child: Text('Error: ${snap.error}'));
                        final list = snap.data ?? [];
                        if (list.isEmpty)
                          return const Center(child: Text('No requests'));
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final req = list[idx];
                            return ListTile(
                              title: Text(req.organizationName),
                              subtitle: Text('${req.email} • ${req.phone}'),
                              trailing: Text(req.status),
                              onTap: () => showModalBottomSheet(
                                context: context,
                                builder: (_) => Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req.organizationName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Email: ${req.email}'),
                                      Text('Phone: ${req.phone}'),
                                      Text('Submitted: ${req.submittedAt}'),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                _confirmApprove(req),
                                            child: const Text('Approve'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _rejectWithReason(req),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Reject'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
