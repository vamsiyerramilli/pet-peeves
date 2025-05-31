import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'home_screen.dart';
import 'pet_onboarding_screen.dart';

class PetSuccessScreen extends StatelessWidget {
  final String userId;
  final String petName;

  const PetSuccessScreen({
    super.key,
    required this.userId,
    required this.petName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 24),
              
              Text(
                '$petName has been added!',
                style: AppTheme.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Would you like to add another pet or go to home?',
                style: AppTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Primary CTA - Go to Home
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(userId: userId),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Go to Home'),
              ),
              const SizedBox(height: 16),

              // Secondary CTA - Add Another Pet
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => PetOnboardingScreen(userId: userId),
                    ),
                  );
                },
                child: const Text('Add Another Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 