import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/store/app_state.dart';
import '../../../core/store/actions.dart';
import 'pet_onboarding_screen.dart';

class PetSuccessScreen extends StatefulWidget {
  final String userId;
  final String petName;

  const PetSuccessScreen({
    super.key,
    required this.userId,
    required this.petName,
  });

  @override
  State<PetSuccessScreen> createState() => _PetSuccessScreenState();
}

class _PetSuccessScreenState extends State<PetSuccessScreen> {
  bool _isNavigatingHome = false;

  void _goToHome(BuildContext context) async {
    setState(() {
      _isNavigatingHome = true;
    });

    final store = StoreProvider.of<AppState>(context, listen: false);
    
    // Refresh pets in Redux to pick up the new pet
    store.dispatch(LoadPetsAction(widget.userId));
    
    // Give a moment for the action to process
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      // Pop all routes to go back to main app
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _addAnotherPet(BuildContext context) {
    // Navigate to another onboarding
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PetOnboardingScreen(userId: widget.userId),
      ),
    );
  }

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
                '${widget.petName} has been added!',
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
                onPressed: _isNavigatingHome ? null : () => _goToHome(context),
                child: _isNavigatingHome 
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Loading...'),
                      ],
                    )
                  : const Text('Go to Home'),
              ),
              const SizedBox(height: 16),

              // Secondary CTA - Add Another Pet
              OutlinedButton(
                onPressed: _isNavigatingHome ? null : () => _addAnotherPet(context),
                child: const Text('Add Another Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 