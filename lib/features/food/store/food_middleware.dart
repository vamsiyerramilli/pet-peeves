import 'package:redux/redux.dart';
import '../../../core/store/app_state.dart';
import '../models/food.dart';
import '../models/food_tracking_entry.dart';
import '../services/food_service.dart';
import 'food_actions.dart';
import 'food_state.dart';
import 'food_tracking_state.dart';

List<Middleware<AppState>> createFoodMiddleware(FoodService foodService) {
  return [
    TypedMiddleware<AppState, LoadFoodsAction>(_loadFoods(foodService)),
    TypedMiddleware<AppState, AddFoodAction>(_addFood(foodService)),
    TypedMiddleware<AppState, UpdateFoodAction>(_updateFood(foodService)),
    TypedMiddleware<AppState, DeleteFoodAction>(_deleteFood(foodService)),
    TypedMiddleware<AppState, LoadFoodEntriesAction>(_loadFoodEntries(foodService)),
    TypedMiddleware<AppState, AddFoodEntryAction>(_addFoodEntry(foodService)),
    TypedMiddleware<AppState, UpdateFoodEntryAction>(_updateFoodEntry(foodService)),
    TypedMiddleware<AppState, DeleteFoodEntryAction>(_deleteFoodEntry(foodService)),
  ];
}

Middleware<AppState> _loadFoods(FoodService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! LoadFoodsAction) return next(action);

    next(action);

    try {
      final userId = store.state.auth.userId;
      if (userId == null) throw Exception('User not authenticated');

      final foods = await service.getFoods(userId);
      store.dispatch(LoadFoodsSuccessAction(foods));
    } catch (e) {
      store.dispatch(LoadFoodsFailureAction(e.toString()));
    }
  };
}

Middleware<AppState> _addFood(FoodService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! AddFoodAction) return next(action);

    next(action);

    try {
      final userId = store.state.auth.userId;
      if (userId == null) throw Exception('User not authenticated');

      if (action.optimistic) {
        final food = await service.addFood(userId, action.food);
        store.dispatch(AddFoodSuccessAction(food, wasOptimistic: true));
      } else {
        final food = await service.addFood(userId, action.food);
        store.dispatch(AddFoodSuccessAction(food));
      }
    } catch (e) {
      store.dispatch(AddFoodFailureAction(e.toString(), action.food));
    }
  };
}

Middleware<AppState> _updateFood(FoodService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! UpdateFoodAction) return next(action);

    next(action);

    try {
      final userId = store.state.auth.userId;
      if (userId == null) throw Exception('User not authenticated');

      if (action.optimistic) {
        final food = await service.updateFood(userId, action.food);
        store.dispatch(UpdateFoodSuccessAction(food, wasOptimistic: true));
      } else {
        final food = await service.updateFood(userId, action.food);
        store.dispatch(UpdateFoodSuccessAction(food));
      }
    } catch (e) {
      store.dispatch(UpdateFoodFailureAction(e.toString(), action.food));
    }
  };
}

Middleware<AppState> _deleteFood(FoodService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! DeleteFoodAction) return next(action);

    next(action);

    try {
      final userId = store.state.auth.userId;
      if (userId == null) throw Exception('User not authenticated');

      if (action.optimistic) {
        await service.deleteFood(userId, action.foodId);
        store.dispatch(DeleteFoodSuccessAction(action.foodId, wasOptimistic: true));
      } else {
        await service.deleteFood(userId, action.foodId);
        store.dispatch(DeleteFoodSuccessAction(action.foodId));
      }
    } catch (e) {
      store.dispatch(DeleteFoodFailureAction(e.toString(), action.foodId));
    }
  };
}

Middleware<AppState> _loadFoodEntries(FoodService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! LoadFoodEntriesAction) return next(action);

    next(action);

    try {
      final userId = store.state.auth.userId;
      if (userId == null) throw Exception('User not authenticated');

      final entries = await service.getFoodTrackingEntries(
        userId,
        action.petId,
        startDate: action.startDate,
        endDate: action.endDate,
      );
      store.dispatch(LoadFoodEntriesSuccessAction(action.petId, entries));
    } catch (e) {
      store.dispatch(LoadFoodEntriesFailureAction(e.toString(), action.petId));
    }
  };
}

Middleware<AppState> _addFoodEntry(FoodService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! AddFoodEntryAction) return next(action);

    next(action);

    try {
      final userId = store.state.auth.userId;
      if (userId == null) throw Exception('User not authenticated');

      if (action.optimistic) {
        final entry = await service.addFoodTrackingEntry(userId, action.entry);
        store.dispatch(AddFoodEntrySuccessAction(entry, wasOptimistic: true));
      } else {
        final entry = await service.addFoodTrackingEntry(userId, action.entry);
        store.dispatch(AddFoodEntrySuccessAction(entry));
      }
    } catch (e) {
      store.dispatch(AddFoodEntryFailureAction(e.toString(), action.entry));
    }
  };
}

Middleware<AppState> _updateFoodEntry(FoodService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! UpdateFoodEntryAction) return next(action);

    next(action);

    try {
      final userId = store.state.auth.userId;
      if (userId == null) throw Exception('User not authenticated');

      if (action.optimistic) {
        final entry = await service.updateFoodTrackingEntry(userId, action.entry);
        store.dispatch(UpdateFoodEntrySuccessAction(entry, wasOptimistic: true));
      } else {
        final entry = await service.updateFoodTrackingEntry(userId, action.entry);
        store.dispatch(UpdateFoodEntrySuccessAction(entry));
      }
    } catch (e) {
      store.dispatch(UpdateFoodEntryFailureAction(e.toString(), action.entry));
    }
  };
}

Middleware<AppState> _deleteFoodEntry(FoodService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! DeleteFoodEntryAction) return next(action);

    next(action);

    try {
      final userId = store.state.auth.userId;
      if (userId == null) throw Exception('User not authenticated');

      if (action.optimistic) {
        await service.deleteFoodTrackingEntry(userId, action.petId, action.entryId);
        store.dispatch(DeleteFoodEntrySuccessAction(action.entryId, wasOptimistic: true));
      } else {
        await service.deleteFoodTrackingEntry(userId, action.petId, action.entryId);
        store.dispatch(DeleteFoodEntrySuccessAction(action.entryId, wasOptimistic: true));
      }
    } catch (e) {
      store.dispatch(DeleteFoodEntryFailureAction(e.toString(), action.petId, action.entryId));
    }
  };
} 