import 'package:flutter/material.dart';
import '../src/theme/design_system.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GatherColors.background,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Privacy Policy placeholder. Replace with real policy text or a webview.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
