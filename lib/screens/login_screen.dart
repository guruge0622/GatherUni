import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../src/shared.dart';
import '../src/backend/firebase_service.dart';
import '../src/features/auth/auth_service.dart';
import '../src/ui/feedback.dart';

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

  Future<void> _signInWithGoogle() async {
    try {
      UIFeedback.showLoading(context, message: 'Signing in...');
      await AuthService.instance.signInWithGoogle();

      final uid = AuthService.instance.currentUser?.uid;
      if (uid == null) {
        if (mounted) UIFeedback.hideLoading(context);
        _showError('Sign-in succeeded but no user id was found.');
        return;
      }

      final profile = await FirebaseService.instance.fetchUserProfileMap(uid);
      if (mounted) UIFeedback.hideLoading(context);

      if (profile == null ||
          (profile['name'] == null || profile['name'].toString().isEmpty)) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/onboarding');
      } else {
        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) UIFeedback.hideLoading(context);
      _showError('Google sign-in failed: ${e.toString()}');
    }
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
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.inputBorder.withValues(alpha: .45),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Sign in with',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.inputBorder.withValues(alpha: .45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                label: const Text('Continue with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.inputBorder),
                  ),
                ),
              ),
            ),
          ],
        ),
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
