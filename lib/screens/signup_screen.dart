import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/components/custom_button.dart';

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

String _passwordStrengthLabel(String pwd) {
  int score = 0;
  if (pwd.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(pwd)) score++;
  if (RegExp(r'[0-9]').hasMatch(pwd)) score++;
  if (RegExp(r'[!@#\$%\^&\*(),.?":{}|<>]').hasMatch(pwd)) score++;
  switch (score) {
    case 0:
    case 1:
      return 'Weak';
    case 2:
      return 'Fair';
    case 3:
      return 'Strong';
    default:
      return 'Very Strong';
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _degree;
  String? _faculty;
  bool _agree = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _showError(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    if (name.isEmpty) {
      return _showError('Enter your full name');
    }
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(email)) {
      return _showError('Enter a valid email');
    }
    if (pass.length < 6) {
      return _showError('Password must be at least 6 characters');
    }
    if (pass != confirm) {
      return _showError('Passwords do not match');
    }
    if (!_agree) {
      return _showError('You must agree to personal data processing');
    }
    if (_faculty == null || _faculty!.isEmpty) {
      return _showError('Please select your faculty');
    }
    if (_degree == null || _degree!.isEmpty) {
      return _showError('Please select your degree programme');
    }

    updateLocalProfile(
      fullName: name,
      email: email,
      role: 'Student',
      faculty: _faculty,
      degree: _degree,
    );

    // UI-only: simulate success and navigate to onboarding
    if (mounted) Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    // UI-only mode: no async loading state
    return AuthScaffold(
      title: 'Get Started',
      showBack: true,
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Full name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Strength: ${_passwordStrengthLabel(_passCtrl.text)}',
              style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: Icon(Icons.verified_user_outlined),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _faculty,
          isExpanded: true,
          isDense: true,
          items: _facultyDegrees.keys
              .map(
                (f) => DropdownMenuItem(
                  value: f,
                  child: Text(f, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _faculty = v;
            _degree = null; // reset degree when faculty changes
          }),
          decoration: const InputDecoration(labelText: 'Faculty'),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _degree,
          isExpanded: true,
          isDense: true,
          items: (_faculty != null && _facultyDegrees[_faculty] != null)
              ? _facultyDegrees[_faculty]!
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(
                          d,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList()
              : [],
          onChanged: _faculty == null
              ? null
              : (v) => setState(() => _degree = v),
          decoration: const InputDecoration(labelText: 'Degree Programme'),
          disabledHint: const Text('Select faculty first'),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: _agree,
              onChanged: (v) => setState(() => _agree = v ?? false),
              activeColor: AppColors.primaryBlue,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the processing of ',
                  children: [
                    TextSpan(
                      text: 'Personal data',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomButton(label: 'Sign up', onPressed: _submit),
        const SizedBox(height: 22),
        const SocialSignInRow(),
        const SizedBox(height: 18),
        AuthSwitch(
          text: 'Already have an account?',
          action: 'Sign in',
          onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
        ),
      ],
    );
  }
}
