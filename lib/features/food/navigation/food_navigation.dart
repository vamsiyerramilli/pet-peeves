import 'package:flutter/material.dart';
import '../screens/food_management_screen.dart';
import '../screens/food_tracking_screen.dart';

class FoodNavigation {
  static const String foodManagementRoute = '/food/manage';
  static const String foodTrackingRoute = '/food/track';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      foodManagementRoute: (context) => const FoodManagementScreen(),
      foodTrackingRoute: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as FoodTrackingScreenArgs;
        return FoodTrackingScreen(petId: args.petId);
      },
    };
  }

  static void navigateToFoodManagement(BuildContext context) {
    Navigator.pushNamed(context, foodManagementRoute);
  }

  static void navigateToFoodTracking(BuildContext context, String petId) {
    Navigator.pushNamed(
      context,
      foodTrackingRoute,
      arguments: FoodTrackingScreenArgs(petId: petId),
    );
  }
}

class FoodTrackingScreenArgs {
  final String petId;

  const FoodTrackingScreenArgs({required this.petId});
} 