import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/user_model.dart';
import '../../pets/screens/pet_onboarding_screen.dart';

class SignupSuccessScreen extends StatelessWidget {
  final UserModel user;

  const SignupSuccessScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 24),
              
              // Welcome Text
              Text(
                'Welcome, ${user.name}!',
                style: AppTheme.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your account has been created successfully.',
                style: AppTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Continue Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetOnboardingScreen(
                        userId: user.uid,
                      ),
                    ),
                  );
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text(
                  'Continue',
                  style: AppTheme.buttonTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 