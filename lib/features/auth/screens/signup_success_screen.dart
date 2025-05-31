import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../models/user_model.dart';
import '../../pets/screens/pet_onboarding_screen.dart';
import '../../pets/screens/home_screen.dart';

class SignupSuccessScreen extends StatefulWidget {
  final UserModel user;

  const SignupSuccessScreen({
    super.key,
    required this.user,
  });

  @override
  State<SignupSuccessScreen> createState() => _SignupSuccessScreenState();
}

class _SignupSuccessScreenState extends State<SignupSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRedirect();
  }

  Future<void> _checkAndRedirect() async {
    // Wait for animations
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    // Check if user has pets
    final petsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .collection('pets')
        .limit(1)
        .get();

    if (!mounted) return;

    if (petsSnapshot.docs.isEmpty) {
      // No pets, go to onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PetOnboardingScreen(userId: widget.user.uid),
        ),
      );
    } else {
      // Has pets, go to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userId: widget.user.uid),
        ),
      );
    }
  }

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
                'Welcome, ${widget.user.name}!',
                style: AppTheme.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your account has been created successfully.',
                style: AppTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 