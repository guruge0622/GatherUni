import 'package:flutter/material.dart';
import '../src/theme/design_system.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GatherColors.background,
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Terms & Conditions placeholder. Replace with full terms content.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
