import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter/foundation.dart';
import '../../features/food/store/food_state.dart';
import '../../features/food/store/food_tracking_state.dart';
import '../../features/auth/models/user_model.dart';

enum AppTab {
  home,
  logs,
  petInfo,
}

@immutable
class AppState {
  final NavigationState navigation;
  final AuthState auth;
  final PetsState pets;
  final FoodState food;
  final FoodTrackingState foodTracking;

  const AppState({
    required this.navigation,
    required this.auth,
    required this.pets,
    required this.food,
    required this.foodTracking,
  });

  factory AppState.initial() {
    return AppState(
      navigation: NavigationState.initial(),
      auth: AuthState.initial(),
      pets: PetsState.initial(),
      food: FoodState.initial(),
      foodTracking: FoodTrackingState.initial(),
    );
  }

  AppState copyWith({
    NavigationState? navigation,
    AuthState? auth,
    PetsState? pets,
    FoodState? food,
    FoodTrackingState? foodTracking,
  }) {
    return AppState(
      navigation: navigation ?? this.navigation,
      auth: auth ?? this.auth,
      pets: pets ?? this.pets,
      food: food ?? this.food,
      foodTracking: foodTracking ?? this.foodTracking,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState &&
        other.navigation == navigation &&
        other.auth == auth &&
        other.pets == pets &&
        other.food == food &&
        other.foodTracking == foodTracking;
  }

  @override
  int get hashCode {
    return Object.hash(
      navigation,
      auth,
      pets,
      food,
      foodTracking,
    );
  }
}

@immutable
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(
      user: null,
      isLoading: false,
      error: null,
    );
  }

  String? get userId => user?.uid;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.user == user &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      user,
      isLoading,
      error,
    );
  }
}

@immutable
class NavigationState {
  final AppTab activeTab;
  final Map<AppTab, double> scrollPositions;

  const NavigationState({
    required this.activeTab,
    required this.scrollPositions,
  });

  factory NavigationState.initial() {
    return NavigationState(
      activeTab: AppTab.home,
      scrollPositions: {},
    );
  }

  NavigationState copyWith({
    AppTab? activeTab,
    Map<AppTab, double>? scrollPositions,
  }) {
    return NavigationState(
      activeTab: activeTab ?? this.activeTab,
      scrollPositions: scrollPositions ?? this.scrollPositions,
    );
  }
}

@immutable
class PetsState {
  final List<String> petIds;
  final String? activePetId;
  final bool isLoading;
  final String? error;

  const PetsState({
    required this.petIds,
    this.activePetId,
    this.isLoading = false,
    this.error,
  });

  factory PetsState.initial() {
    return const PetsState(
      petIds: [],
      activePetId: null,
      isLoading: false,
      error: null,
    );
  }

  PetsState copyWith({
    List<String>? petIds,
    String? activePetId,
    bool? isLoading,
    String? error,
  }) {
    return PetsState(
      petIds: petIds ?? this.petIds,
      activePetId: activePetId ?? this.activePetId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Helper method to initialize active pet
  PetsState initializeActivePet() {
    if (activePetId == null && petIds.isNotEmpty) {
      return copyWith(activePetId: petIds.first);
    }
    return this;
  }
} 