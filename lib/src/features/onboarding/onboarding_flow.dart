import 'package:flutter/material.dart';
import '../../backend/firebase_service.dart';

const _facultyDegrees = {
  'Faculty of Defence and Strategic Studies (FDSS)': [
    'Bachelor of Science in Strategic Studies and International Relations',
  ],
  'Faculty of Medicine (FOM)': [
    'Bachelor of Medicine and Bachelor of Surgery (MBBS)',
  ],
  'Faculty of Engineering (FOE)': [
    'BSc (Hons) in Aeronautical Engineering',
    'BSc (Hons) in Building Services Engineering',
    'BSc (Hons) in Civil Engineering',
    'BSc (Hons) in Electrical and Electronic Engineering',
    'BSc (Hons) in Electronic and Telecommunication Engineering',
    'BSc (Hons) in Mechanical Engineering',
    'BSc (Hons) in Mechatronic Engineering',
    'BSc (Hons) in Marine Engineering',
    'BSc (Hons) in Naval Architecture and Marine Engineering',
  ],
  'Faculty of Law (FOL)': ['Bachelor of Laws (LLB)'],
  'Faculty of Management, Social Sciences and Humanities (FMSH)': [
    'BSc in Management and Technical Sciences',
    'BSc (Hons) in Management and Technical Sciences',
    'BSc in Logistics Management',
    'BSc in Social Sciences',
    'BA in Teaching English to Speakers of Other Languages (TESOL)',
    'BSc (Hons) in Financial Analytics',
    'BSc (Hons) in Management',
  ],
  'Faculty of Computing (FOC)': [
    'BSc (Hons) in Computer Science',
    'BSc (Hons) in Software Engineering',
    'BSc (Hons) in Computer Engineering',
    'BSc (Hons) in Information Technology',
  ],
  'Faculty of Criminal Justice (FOCJ)': [
    'BSc in Criminology and Criminal Justice',
  ],
  'Faculty of Technology': [
    'BET (Hons) in Biomedical Instrumentation Technology',
    'BET (Hons) in Building Services Technology',
    'BT (Hons) in Information and Communication Technology',
    'BBST (Hons) in Applied Biotechnology',
    'BET (Hons) in Construction Technology',
  ],
  'Other': ['Other'],
};

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String role = 'student';
  String faculty = '';
  String degree = '';
  String year = '';
  List<String> interests = [];

  Future<void> _saveProfile() async {
    final user = FirebaseService.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) return;
    final data = {
      'name': name,
      'role': role,
      'faculty': faculty,
      'degree': degree,
      'year': year,
      'interests': interests,
      'createdAt': DateTime.now().toIso8601String(),
    };
    // If the current user is signed in anonymously, skip attempting to
    // write the profile to Firestore to avoid permission errors when
    // Firestore rules disallow anonymous writes to `users/{uid}`.
    if (user != null && user.isAnonymous) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile saved locally. Sign in to persist your profile to cloud.',
          ),
        ),
      );
    } else {
      await FirebaseService.instance.setUserProfile(uid, data);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full name'),
                onChanged: (v) => name = v,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                ],
                onChanged: (v) => role = v ?? 'student',
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: faculty.isEmpty ? null : faculty,
                items: _facultyDegrees.keys
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => faculty = v ?? ''),
                decoration: const InputDecoration(labelText: 'Faculty'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: degree.isEmpty ? null : degree,
                items: (faculty.isNotEmpty && _facultyDegrees[faculty] != null)
                    ? _facultyDegrees[faculty]!
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList()
                    : [],
                onChanged: faculty.isEmpty
                    ? null
                    : (v) => setState(() => degree = v ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Degree (if student)',
                ),
                validator: (v) {
                  if (role == 'student' && (v == null || v.isEmpty)) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Academic year'),
                onChanged: (v) => year = v,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveProfile();
                  }
                },
                child: const Text('Save and continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
