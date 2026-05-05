import 'package:flutter/material.dart';
import '../src/shared.dart';

final _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _remember = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (!_emailRegex.hasMatch(email)) {
      _showError('Please enter a valid email.');
      return;
    }
    if (pass.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }
    // UI-only: simulate successful sign in
    if (mounted) Navigator.of(context).pushReplacementNamed('/main');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // UI-only mode: no async loading state

    return AuthScaffold(
      title: 'Welcome back',
      showBack: true,
      children: [
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
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: _remember,
              onChanged: (v) => setState(() => _remember = v ?? true),
              activeColor: AppColors.primaryBlue,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const Expanded(
              child: Text(
                'Remember me',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = _emailCtrl.text.trim();
                if (!_emailRegex.hasMatch(email)) {
                  _showError('Enter your email to reset password');
                  return;
                }
                _showError('Password reset email sent (simulated).');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _submit, child: const Text('Sign in')),
        const SizedBox(height: 22),
        const SocialSignInRow(),
        const SizedBox(height: 18),
        AuthSwitch(
          text: "Don't have an account?",
          action: 'Sign up',
          onTap: () => Navigator.of(context).pushNamed('/signup'),
        ),
      ],
    );
  }
}
