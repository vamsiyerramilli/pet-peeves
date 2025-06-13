import 'package:redux/redux.dart';
import 'food_tracking_state.dart';
import 'food_actions.dart';
import '../models/food_tracking_entry.dart';

final foodTrackingReducer = combineReducers<FoodTrackingState>([
  TypedReducer<FoodTrackingState, LoadFoodEntriesAction>(_onLoadEntries),
  TypedReducer<FoodTrackingState, LoadFoodEntriesSuccessAction>(_onLoadEntriesSuccess),
  TypedReducer<FoodTrackingState, LoadFoodEntriesFailureAction>(_onLoadEntriesFailure),
  
  TypedReducer<FoodTrackingState, AddFoodEntryAction>(_onAddEntry),
  TypedReducer<FoodTrackingState, AddFoodEntrySuccessAction>(_onAddEntrySuccess),
  TypedReducer<FoodTrackingState, AddFoodEntryFailureAction>(_onAddEntryFailure),
  
  TypedReducer<FoodTrackingState, UpdateFoodEntryAction>(_onUpdateEntry),
  TypedReducer<FoodTrackingState, UpdateFoodEntrySuccessAction>(_onUpdateEntrySuccess),
  TypedReducer<FoodTrackingState, UpdateFoodEntryFailureAction>(_onUpdateEntryFailure),
  
  TypedReducer<FoodTrackingState, DeleteFoodEntryAction>(_onDeleteEntry),
  TypedReducer<FoodTrackingState, DeleteFoodEntrySuccessAction>(_onDeleteEntrySuccess),
  TypedReducer<FoodTrackingState, DeleteFoodEntryFailureAction>(_onDeleteEntryFailure),
]);

// Load Reducers
FoodTrackingState _onLoadEntries(FoodTrackingState state, LoadFoodEntriesAction action) {
  return state.copyWith(
    isLoading: true,
    error: null,
  );
}

FoodTrackingState _onLoadEntriesSuccess(FoodTrackingState state, LoadFoodEntriesSuccessAction action) {
  final newMap = Map<String, List<FoodTrackingEntry>>.from(state.entriesByPet)
    ..[action.petId] = action.entries;
  return state.copyWith(entriesByPet: newMap, isLoading: false, error: null);
}

FoodTrackingState _onLoadEntriesFailure(FoodTrackingState state, LoadFoodEntriesFailureAction action) {
  return state.copyWith(
    isLoading: false,
    error: action.error,
  );
}

// Add Reducers
FoodTrackingState _onAddEntry(FoodTrackingState state, AddFoodEntryAction action) {
  if (action.optimistic) {
    return state.addEntry(action.entry.petId, action.entry);
  }
  return state;
}

FoodTrackingState _onAddEntrySuccess(FoodTrackingState state, AddFoodEntrySuccessAction action) {
  return state.addEntry(action.entry.petId, action.entry);
}

FoodTrackingState _onAddEntryFailure(FoodTrackingState state, AddFoodEntryFailureAction action) {
  // Rollback optimistic add if needed
  if (action.wasOptimistic) {
    final updated = state.deleteEntry(action.entry.petId, action.entry.id);
    return updated.copyWith(error: action.error);
  }
  return state.copyWith(error: action.error);
}

// Update Reducers
FoodTrackingState _onUpdateEntry(FoodTrackingState state, UpdateFoodEntryAction action) {
  if (action.optimistic) {
    return state.updateEntry(action.entry.petId, action.entry);
  }
  return state;
}

FoodTrackingState _onUpdateEntrySuccess(FoodTrackingState state, UpdateFoodEntrySuccessAction action) {
  return state.updateEntry(action.entry.petId, action.entry);
}

FoodTrackingState _onUpdateEntryFailure(FoodTrackingState state, UpdateFoodEntryFailureAction action) {
  return state.copyWith(error: action.error);
}

// Delete Reducers
FoodTrackingState _onDeleteEntry(FoodTrackingState state, DeleteFoodEntryAction action) {
  if (action.optimistic) {
    return state.deleteEntry(action.petId, action.entryId);
  }
  return state;
}

FoodTrackingState _onDeleteEntrySuccess(FoodTrackingState state, DeleteFoodEntrySuccessAction action) {
  // We don't have petId in success action; assume it was already removed optimistically or reload after service.
  return state;
}

FoodTrackingState _onDeleteEntryFailure(FoodTrackingState state, DeleteFoodEntryFailureAction action) {
  return state.copyWith(error: action.error);
} 