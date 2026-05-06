import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/components/custom_button.dart';

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
    // Faculty and degree are collected in onboarding; skip here.

    updateLocalProfile(fullName: name, email: email, role: 'Student');

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
        // Faculty and degree selection moved to onboarding flow.
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
