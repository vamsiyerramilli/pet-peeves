import 'package:redux/redux.dart';
import 'food_state.dart';
import 'food_actions.dart';
import '../models/food.dart';

FoodState foodReducer(FoodState state, dynamic action) {
  // Load foods
  if (action is LoadFoodsAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is LoadFoodsSuccessAction) {
    print('FOOD_REDUCER: foods loaded: ' + action.foods.length.toString());
    return state.copyWith(
      isLoading: false,
      foods: action.foods,
      error: null,
    );
  }

  if (action is LoadFoodsFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  // Add food
  if (action is AddFoodAction) {
    print('FOOD_REDUCER: AddFoodAction for food: \\${action.food.name}');
    if (action.optimistic) {
      final foods = List<Food>.from(state.foods)..add(action.food);
      return state.copyWith(
        foods: foods,
        error: null,
      );
    }
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is AddFoodSuccessAction) {
    print('FOOD_REDUCER: AddFoodSuccessAction for food: \\${action.food.name}');
    if (!action.wasOptimistic) {
      final foods = List<Food>.from(state.foods)..add(action.food);
      return state.copyWith(
        isLoading: false,
        foods: foods,
        error: null,
      );
    }
    return state.copyWith(isLoading: false);
  }

  if (action is AddFoodFailureAction) {
    print('FOOD_REDUCER: AddFoodFailureAction: \\${action.error}');
    if (action.wasOptimistic) {
      final foods = List<Food>.from(state.foods)
        ..removeWhere((f) => f.id == action.food.id);
      return state.copyWith(
        isLoading: false,
        foods: foods,
        error: action.error,
      );
    }
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  // Update food
  if (action is UpdateFoodAction) {
    if (action.optimistic) {
      final foods = List<Food>.from(state.foods);
      final index = foods.indexWhere((f) => f.id == action.food.id);
      if (index != -1) {
        foods[index] = action.food;
      }
      return state.copyWith(
        foods: foods,
        error: null,
      );
    }
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is UpdateFoodSuccessAction) {
    if (!action.wasOptimistic) {
      final foods = List<Food>.from(state.foods);
      final index = foods.indexWhere((f) => f.id == action.food.id);
      if (index != -1) {
        foods[index] = action.food;
      }
      return state.copyWith(
        isLoading: false,
        foods: foods,
        error: null,
      );
    }
    return state.copyWith(isLoading: false);
  }

  if (action is UpdateFoodFailureAction) {
    if (action.wasOptimistic) {
      final foods = List<Food>.from(state.foods);
      final index = foods.indexWhere((f) => f.id == action.food.id);
      if (index != -1) {
        foods[index] = action.food;
      }
      return state.copyWith(
        isLoading: false,
        foods: foods,
        error: action.error,
      );
    }
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  // Delete food
  if (action is DeleteFoodAction) {
    if (action.optimistic) {
      final foods = List<Food>.from(state.foods)
        ..removeWhere((f) => f.id == action.foodId);
      return state.copyWith(
        foods: foods,
        error: null,
      );
    }
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is DeleteFoodSuccessAction) {
    if (!action.wasOptimistic) {
      final foods = List<Food>.from(state.foods)
        ..removeWhere((f) => f.id == action.foodId);
      return state.copyWith(
        isLoading: false,
        foods: foods,
        error: null,
      );
    }
    return state.copyWith(isLoading: false);
  }

  if (action is DeleteFoodFailureAction) {
    if (action.wasOptimistic) {
      // TODO: Restore the deleted food if we have it
      return state.copyWith(
        isLoading: false,
        error: action.error,
      );
    }
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  return state;
} 