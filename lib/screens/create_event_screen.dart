import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../src/shared.dart';
import '../src/ui/feedback.dart';
import '../src/theme/design_system.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  Event? _editing;
  bool _didInitArgs = false;

  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();
  final _tags = TextEditingController();

  String _category = 'Academics';
  DateTime? _start;
  DateTime? _end;
  bool _isOnline = false;
  bool _isPaid = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Event) {
      _editing = args;
      _title.text = _editing!.title;
      _desc.text = _editing!.description;
      _location.text = _editing!.location;
      _price.text = _editing!.price.toString();
      _category = _editing!.category;
      _isOnline = _editing!.location.toLowerCase() == 'online';
      _didInitArgs = true;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _location.dispose();
    _price.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (d == null) return;
    if (!mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (!mounted) return;
    final dt = DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);
    setState(() => isStart ? _start = dt : _end = dt);
  }

  Future<void> _saveDraft() async {
    final id = _editing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final e = Event(
      id: id,
      title: _title.text.trim(),
      category: _category,
      date: _start == null ? '' : DateFormat.yMMMMd().format(_start!),
      time: _start == null ? '' : DateFormat.jm().format(_start!),
      location: _isOnline ? 'Online' : _location.text.trim(),
      price: double.tryParse(_price.text) ?? 0.0,
      description: _desc.text.trim(),
      colors: [AppColors.primaryBlue, AppColors.lightBlue],
      bookings: 0,
      isDraft: true,
      organizer: localProfile.value.organizationName.isEmpty
          ? localProfile.value.fullName
          : localProfile.value.organizationName,
    );

    try {
      UIFeedback.showLoading(context, message: 'Saving draft...');
      if (_editing != null) {
        await editUserEvent(id, e);
      } else {
        await addUserEvent(e);
      }
      UIFeedback.hideLoading(context);
      if (!mounted) return;
      UIFeedback.showSnack(context, 'Draft saved');
      Navigator.of(context).pushNamed('/organizer/dashboard');
    } catch (err) {
      UIFeedback.hideLoading(context);
      if (!mounted) return;
      UIFeedback.showSnack(
        context,
        'Failed to save draft: ${err.toString()}',
        success: false,
      );
    }
  }

  Future<void> _publish() async {
    final id = _editing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final e = Event(
      id: id,
      title: _title.text.trim(),
      category: _category,
      date: _start == null ? '' : DateFormat.yMMMMd().format(_start!),
      time: _start == null ? '' : DateFormat.jm().format(_start!),
      location: _isOnline ? 'Online' : _location.text.trim(),
      price: double.tryParse(_price.text) ?? 0.0,
      description: _desc.text.trim(),
      colors: [AppColors.primaryBlue, AppColors.lightBlue],
      bookings: 0,
      isDraft: false,
      organizer: localProfile.value.organizationName.isEmpty
          ? localProfile.value.fullName
          : localProfile.value.organizationName,
    );

    try {
      UIFeedback.showLoading(context, message: 'Publishing event...');
      if (_editing != null) {
        await editUserEvent(id, e);
      } else {
        await addUserEvent(e);
      }
      UIFeedback.hideLoading(context);
      if (!mounted) return;
      UIFeedback.showSnack(context, 'Event published');
      Navigator.of(context).pushNamed('/organizer/dashboard');
    } catch (err) {
      UIFeedback.hideLoading(context);
      if (!mounted) return;
      UIFeedback.showSnack(
        context,
        'Failed to publish: ${err.toString()}',
        success: false,
      );
    }
  }

  void _preview() {
    final id = _editing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final e = Event(
      id: id,
      title: _title.text.trim(),
      category: _category,
      date: _start == null ? '' : DateFormat.yMMMMd().format(_start!),
      time: _start == null ? '' : DateFormat.jm().format(_start!),
      location: _isOnline ? 'Online' : _location.text.trim(),
      price: double.tryParse(_price.text) ?? 0.0,
      description: _desc.text.trim(),
      colors: [AppColors.primaryBlue, AppColors.lightBlue],
      bookings: 0,
      isDraft: false,
      organizer: localProfile.value.organizationName.isEmpty
          ? localProfile.value.fullName
          : localProfile.value.organizationName,
    );
    Navigator.of(context).pushNamed('/organizer/preview', arguments: e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      backgroundColor: GatherColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              _sectionCard(
                title: 'Basic Info',
                child: Column(
                  children: [
                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: ['Academics', 'Tech', 'Cultural', 'Sports', 'Arts']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _category = v ?? _category),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _desc,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Short description',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Date & Time',
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        _start == null
                            ? 'Select start'
                            : DateFormat.yMMMMd().add_jm().format(_start!),
                      ),
                      leading: const Icon(Icons.calendar_month_rounded),
                      onTap: () => _pickDate(true),
                    ),
                    ListTile(
                      title: Text(
                        _end == null
                            ? 'Select end'
                            : DateFormat.yMMMMd().add_jm().format(_end!),
                      ),
                      leading: const Icon(Icons.calendar_month_outlined),
                      onTap: () => _pickDate(false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Location / Mode',
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Online event'),
                      value: _isOnline,
                      onChanged: (v) => setState(() => _isOnline = v),
                    ),
                    if (!_isOnline)
                      TextField(
                        controller: _location,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Ticket / Registration',
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Paid event'),
                      value: _isPaid,
                      onChanged: (v) => setState(() => _isPaid = v),
                    ),
                    if (_isPaid)
                      TextField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Tags',
                child: Column(
                  children: [
                    TextField(
                      controller: _tags,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saveDraft,
                      child: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _preview,
                      child: const Text('Preview'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _publish,
                      child: const Text('Publish'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
