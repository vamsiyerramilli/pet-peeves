import 'package:redux/redux.dart';
import 'app_state.dart';
import 'actions.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    navigation: navigationReducer(state.navigation, action),
    pets: petsReducer(state.pets, action),
  );
}

NavigationState navigationReducer(NavigationState state, dynamic action) {
  if (action is SetActiveTabAction) {
    return state.copyWith(activeTab: action.tab);
  } else if (action is UpdateScrollPositionAction) {
    final newPositions = Map<AppTab, double>.from(state.scrollPositions);
    newPositions[action.tab] = action.position;
    return state.copyWith(scrollPositions: newPositions);
  }
  return state;
}

PetsState petsReducer(PetsState state, dynamic action) {
  if (action is LoadPetsAction) {
    return state.copyWith(isLoading: true, error: null);
  } else if (action is LoadPetsSuccessAction) {
    return state.copyWith(
      petIds: action.petIds,
      isLoading: false,
      error: null,
    );
  } else if (action is LoadPetsFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  } else if (action is SetActivePetAction) {
    return state.copyWith(activePetId: action.petId);
  } else if (action is ClearActivePetAction) {
    return state.copyWith(activePetId: null);
  } else if (action is SetPetIdsAction) {
    final newState = state.copyWith(petIds: action.petIds);
    return newState.initializeActivePet();
  }
  return state;
} 