import 'package:flutter/foundation.dart';
import '../models/food.dart';

@immutable
class FoodState {
  final List<Food> foods;
  final bool isLoading;
  final String? error;
  final Map<String, bool> isPendingSyncById;

  const FoodState({
    required this.foods,
    this.isLoading = false,
    this.error,
    required this.isPendingSyncById,
  });

  factory FoodState.initial() {
    return const FoodState(
      foods: [],
      isLoading: false,
      error: null,
      isPendingSyncById: {},
    );
  }

  FoodState copyWith({
    List<Food>? foods,
    bool? isLoading,
    String? error,
    Map<String, bool>? isPendingSyncById,
  }) {
    return FoodState(
      foods: foods ?? this.foods,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isPendingSyncById: isPendingSyncById ?? this.isPendingSyncById,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodState &&
        listEquals(other.foods, foods) &&
        other.isLoading == isLoading &&
        other.error == error &&
        mapEquals(other.isPendingSyncById, isPendingSyncById);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(foods),
      isLoading,
      error,
      Object.hashAll(isPendingSyncById.entries),
    );
  }
} 