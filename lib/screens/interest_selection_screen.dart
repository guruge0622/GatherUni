import 'package:flutter/material.dart';
import '../src/shared.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  State<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final selected = <String>{'Tech', 'Arts'};

  IconData _interestIcon(String interest) {
    switch (interest) {
      case 'Academics':
        return Icons.school_rounded;
      case 'Arts':
        return Icons.palette_rounded;
      case 'Cultural':
        return Icons.diversity_3_rounded;
      case 'Sports':
        return Icons.sports_soccer_rounded;
      case 'Tech':
        return Icons.memory_rounded;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GatherUniLogo(size: 96),
              const SizedBox(height: 28),
              Text(
                'Choose your interests',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Personalized suggestions become smarter when your interests are selected.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: interests.map((interest) {
                  final isSelected = selected.contains(interest);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(interest),
                    avatar: Icon(
                      _interestIcon(interest),
                      size: 18,
                      color: isSelected ? Colors.white : AppColors.primaryBlue,
                    ),
                    onSelected: (_) {
                      setState(() {
                        isSelected
                            ? selected.remove(interest)
                            : selected.add(interest);
                      });
                    },
                    selectedColor: AppColors.primaryBlue,
                    elevation: isSelected ? 6 : 0,
                    pressElevation: 2,
                    shadowColor: AppColors.primaryBlue.withValues(alpha: .18),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.inputBorder.withValues(alpha: .55),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  updateLocalProfile(interests: selected.toList());
                  Navigator.of(context).pushReplacementNamed(
                    '/onboarding/step2',
                  );
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
