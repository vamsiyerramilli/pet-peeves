import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_peeves/providers/auth_provider.dart';
import 'package:pet_peeves/routes/app_router.dart';
import 'package:pet_peeves/services/pet_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = context.read<AuthProvider>();
    
    // Wait for initial auth state
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      final hasPets = await authProvider.hasPets();
      final userId = authProvider.user?.uid;
      final petService = PetService();
      if (hasPets) {
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.onboarding,
          arguments: {
            'userId': userId,
            'petService': petService,
          },
        );
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Add your app logo here
            const Icon(
              Icons.pets,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Pet Peeves',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 