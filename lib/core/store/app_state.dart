import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter/foundation.dart';

enum AppTab {
  home,
  logs,
  petInfo,
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

@immutable
class AppState {
  final NavigationState navigation;
  final PetsState pets;

  const AppState({
    required this.navigation,
    required this.pets,
  });

  factory AppState.initial() {
    return AppState(
      navigation: NavigationState.initial(),
      pets: PetsState.initial(),
    );
  }

  AppState copyWith({
    NavigationState? navigation,
    PetsState? pets,
  }) {
    return AppState(
      navigation: navigation ?? this.navigation,
      pets: pets ?? this.pets,
    );
  }
} 