import 'package:flutter/material.dart';
import '../src/shared.dart';
import '../src/theme/design_system.dart';

class OnboardingPreferencesScreen extends StatefulWidget {
  const OnboardingPreferencesScreen({super.key});

  @override
  State<OnboardingPreferencesScreen> createState() =>
      _OnboardingPreferencesScreenState();
}

class _OnboardingPreferencesScreenState
    extends State<OnboardingPreferencesScreen> {
  String attendance = 'Sometimes';
  String time = 'Evening';
  String budget = 'Under \$20';

  Widget _preferenceCard(
    String title,
    List<String> options,
    String value,
    void Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((opt) {
            final selected = opt == value;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected ? GatherColors.primary : GatherColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? GatherColors.primary
                        : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    color: selected
                        ? GatherColors.white
                        : GatherColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GatherUniLogo(size: 84),
              const SizedBox(height: 20),
              Text(
                'Preferences',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Help us tailor events to your schedule and budget.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              _preferenceCard(
                'Attendance',
                ['Never', 'Sometimes', 'Often', 'Always'],
                attendance,
                (v) => setState(() => attendance = v),
              ),
              const SizedBox(height: 16),
              _preferenceCard(
                'Time',
                ['Morning', 'Afternoon', 'Evening', 'Weekends'],
                time,
                (v) => setState(() => time = v),
              ),
              const SizedBox(height: 16),
              _preferenceCard(
                'Budget',
                ['Free only', 'Under \$5', 'Under \$20', 'No limit'],
                budget,
                (v) => setState(() => budget = v),
              ),

              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed('/onboarding/step3'),
                      child: const Text('Continue'),
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
}
