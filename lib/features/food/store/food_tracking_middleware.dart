import 'package:redux/redux.dart';
import '../../../core/store/app_state.dart';
import '../services/food_service.dart';
import 'food_actions.dart';
import 'food_tracking_actions.dart' as Tracking;

List<Middleware<AppState>> createFoodTrackingMiddleware(FoodService foodService) {
  return [
    // --- Bridging middleware: translate older *Tracking* actions used by UI ----
    TypedMiddleware<AppState, Tracking.LoadFoodTrackingEntries>((store, action, next) {
      store.dispatch(LoadFoodEntriesAction(action.petId));
    }),
    TypedMiddleware<AppState, Tracking.AddFoodTrackingEntry>((store, action, next) {
      store.dispatch(AddFoodEntryAction(action.entry, optimistic: action.optimistic));
    }),
    TypedMiddleware<AppState, Tracking.UpdateFoodTrackingEntry>((store, action, next) {
      store.dispatch(UpdateFoodEntryAction(action.entry, optimistic: action.optimistic));
    }),
    TypedMiddleware<AppState, Tracking.DeleteFoodTrackingEntry>((store, action, next) {
      store.dispatch(DeleteFoodEntryAction(action.petId, action.entryId, optimistic: action.optimistic));
    }),

    TypedMiddleware<AppState, LoadFoodEntriesAction>(_loadFoodEntries(foodService)),
    TypedMiddleware<AppState, AddFoodEntryAction>(_addFoodEntry(foodService)),
    TypedMiddleware<AppState, UpdateFoodEntryAction>(_updateFoodEntry(foodService)),
    TypedMiddleware<AppState, DeleteFoodEntryAction>(_deleteFoodEntry(foodService)),
  ];
}

Middleware<AppState> _loadFoodEntries(FoodService foodService) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    if (action is LoadFoodEntriesAction) {
      try {
        final entries = await foodService.getFoodTrackingEntries(
          store.state.auth.user!.uid,
          action.petId,
          startDate: action.startDate,
          endDate: action.endDate,
        );
        store.dispatch(LoadFoodEntriesSuccessAction(action.petId, entries));
      } catch (e) {
        store.dispatch(LoadFoodEntriesFailureAction(e.toString(), action.petId));
      }
    }
    next(action);
  };
}

Middleware<AppState> _addFoodEntry(FoodService foodService) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    if (action is AddFoodEntryAction) {
      next(action);

      if (action.optimistic) {
        // Do nothing, let the reducer handle the optimistic update.
        return;
      }

      try {
        final entry = await foodService.addFoodTrackingEntry(
          store.state.auth.user!.uid,
          action.entry,
        );
        store.dispatch(AddFoodEntrySuccessAction(entry));
      } catch (e) {
        store.dispatch(AddFoodEntryFailureAction(e.toString(), action.entry));
      }
    }
  };
}

Middleware<AppState> _updateFoodEntry(FoodService foodService) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    if (action is UpdateFoodEntryAction) {
      next(action);

      if (action.optimistic) {
        store.dispatch(UpdateFoodEntrySuccessAction(action.entry, wasOptimistic: true));
        return;
      }

      try {
        final entry = await foodService.updateFoodTrackingEntry(
          store.state.auth.user!.uid,
          action.entry,
        );
        store.dispatch(UpdateFoodEntrySuccessAction(entry));
      } catch (e) {
        store.dispatch(UpdateFoodEntryFailureAction(e.toString(), action.entry));
      }
    }
  };
}

Middleware<AppState> _deleteFoodEntry(FoodService foodService) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    if (action is DeleteFoodEntryAction) {
      next(action);

      if (action.optimistic) {
        store.dispatch(DeleteFoodEntrySuccessAction(action.entryId, wasOptimistic: true));
        return;
      }

      try {
        await foodService.deleteFoodTrackingEntry(
          store.state.auth.user!.uid,
          action.petId,
          action.entryId,
        );
        store.dispatch(DeleteFoodEntrySuccessAction(action.entryId));
      } catch (e) {
        store.dispatch(DeleteFoodEntryFailureAction(e.toString(), action.petId, action.entryId));
      }
    }
  };
} 