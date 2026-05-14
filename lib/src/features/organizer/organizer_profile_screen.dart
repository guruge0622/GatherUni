import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../events/create_event_screen.dart';

class OrganizerProfileScreen extends StatefulWidget {
  const OrganizerProfileScreen({Key? key}) : super(key: key);

  @override
  State<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayName = TextEditingController();
  final _orgName = TextEditingController();
  final _university = TextEditingController();
  final _bio = TextEditingController();
  bool _saving = false;

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data == null) return;
    _displayName.text = (data['displayName'] as String?) ?? '';
    _orgName.text = (data['organizationName'] as String?) ?? '';
    _university.text = (data['university'] as String?) ?? '';
    _bio.text = (data['bio'] as String?) ?? '';
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'displayName': _displayName.text.trim(),
        'organizationName': _orgName.text.trim(),
        'university': _university.text.trim(),
        'bio': _bio.text.trim(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CreateEventScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _displayName.dispose();
    _orgName.dispose();
    _university.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _displayName,
                decoration: const InputDecoration(labelText: 'Display name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orgName,
                decoration: const InputDecoration(
                  labelText: 'Organization name',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _university,
                decoration: const InputDecoration(
                  labelText: 'University (optional)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bio,
                decoration: const InputDecoration(
                  labelText: 'About / Bio (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveAndContinue,
                      child: const Text('Save & Create Event'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
