import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _intakeCtrl;
  late final TextEditingController _orgNameCtrl;
  late final TextEditingController _contactCtrl;
  String _role = 'Student';

  @override
  void initState() {
    super.initState();
    final profile = localProfile.value;
    _nameCtrl = TextEditingController(text: profile.fullName);
    _emailCtrl = TextEditingController(text: profile.email);
    _intakeCtrl = TextEditingController(
      text: profile.intake.isEmpty ? '41' : profile.intake,
    );
    _orgNameCtrl = TextEditingController(text: profile.organizationName);
    _contactCtrl = TextEditingController(text: profile.contactInfo);
    _role = profile.role.isEmpty ? 'Student' : profile.role;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _intakeCtrl.dispose();
    _orgNameCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  void _save() {
    updateLocalProfile(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      intake: _intakeCtrl.text.trim(),
      role: _role,
      organizationName: _orgNameCtrl.text.trim(),
      contactInfo: _contactCtrl.text.trim(),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved')));

    if (_role == 'Organizer') {
      Navigator.of(context).pushReplacementNamed('/organizer/create');
      return;
    }

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      backgroundColor: GatherColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE6ECF6)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _intakeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Intake',
                        hintText: 'Example: 41',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Role',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'Student',
                              label: Text('Student'),
                            ),
                            ButtonSegment(value: 'Staff', label: Text('Staff')),
                            ButtonSegment(
                              value: 'Organizer',
                              label: Text('Organizer'),
                            ),
                          ],
                          selected: {_role},
                          onSelectionChanged: (s) =>
                              setState(() => _role = s.first),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_role == 'Organizer') ...[
                      TextField(
                        controller: _orgNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Organization name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contactCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Contact info (email/phone)',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
