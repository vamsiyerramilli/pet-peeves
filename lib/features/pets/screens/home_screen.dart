import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../core/store/app_state.dart';
import '../../../core/theme/app_theme.dart';
import 'pet_onboarding_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? userId;

  const HomeScreen({
    super.key,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        if (!vm.hasPets) {
          return _buildNoPetsState(context, vm.userId);
        }

        return const Center(
          child: Text('Home Screen - Coming Soon'),
        );
      },
    );
  }

  Widget _buildNoPetsState(BuildContext context, String? userId) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pet illustration
              const Icon(
                Icons.pets,
                size: 120,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 32),
              
              // Welcome message
              Text(
                'Welcome to Pet Peeves!',
                style: AppTheme.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Start by adding your first pet to track their health, food, and activities.',
                style: AppTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Add Pet Button
              FilledButton.icon(
                onPressed: userId != null ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PetOnboardingScreen(userId: userId!),
                    ),
                  );
                } : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Pet'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Features preview
              Text(
                'Track food intake, health records, and growth measurements all in one place.',
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModel {
  final bool hasPets;
  final String? activePetId;
  final String? userId;

  _ViewModel({
    required this.hasPets,
    this.activePetId,
    this.userId,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      hasPets: store.state.pets.petIds.isNotEmpty,
      activePetId: store.state.pets.activePetId,
      userId: store.state.auth.user?.uid,
    );
  }
} 