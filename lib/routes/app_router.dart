import 'package:flutter/material.dart';
import 'package:pet_peeves/screens/auth/login_screen.dart';
import 'package:pet_peeves/screens/auth/onboarding_screen.dart';
import 'package:pet_peeves/screens/dashboard/dashboard_screen.dart';
import 'package:pet_peeves/screens/pet_info/pet_profile_screen.dart';
import 'package:pet_peeves/screens/timeline/timeline_screen.dart';
import 'package:pet_peeves/screens/splash_screen.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/services/pet_service.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String petProfile = '/pet-profile';
  static const String timeline = '/timeline';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        // Extract userId and petService from arguments if provided
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String?;
        final petService = args?['petService'] as PetService?;
        if (userId == null || petService == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('User ID and PetService are required for onboarding'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            userId: userId,
            petService: petService,
          ),
        );
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        // Extract pets from arguments if provided
        final args = settings.arguments as Map<String, dynamic>?;
        final pets = args?['pets'] as List<Pet>?;
        if (pets == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('Pets data is required for dashboard'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(pets: pets),
        );
      case petProfile:
        // Extract pet and petService from arguments if provided
        final args = settings.arguments as Map<String, dynamic>?;
        final pet = args?['pet'] as Pet?;
        final petService = args?['petService'] as PetService?;
        if (pet == null || petService == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('Pet and PetService data are required for pet profile'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => PetProfileScreen(
            pet: pet,
            petService: petService,
          ),
        );
      case timeline:
        // Extract pet and petService from arguments if provided
        final args = settings.arguments as Map<String, dynamic>?;
        final pet = args?['pet'] as Pet?;
        final petService = args?['petService'] as PetService?;
        if (pet == null || petService == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('Pet and PetService data are required for timeline'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => TimelineScreen(
            pet: pet,
            petService: petService,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 