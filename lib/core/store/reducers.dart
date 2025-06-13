import 'package:redux/redux.dart';
import 'app_state.dart';
import 'actions.dart';
import '../../features/food/store/food_tracking_reducer.dart';
import '../../features/food/store/food_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    navigation: navigationReducer(state.navigation, action),
    auth: authReducer(state.auth, action),
    pets: petsReducer(state.pets, action),
    food: foodReducer(state.food, action),
    foodTracking: foodTrackingReducer(state.foodTracking, action),
  );
}

AuthState authReducer(AuthState state, dynamic action) {
  if (action is SignInAction) {
    return state.copyWith(
      isLoading: action.isLoading,
      error: null,
    );
  } else if (action is SignInSuccessAction) {
    return state.copyWith(
      user: action.user,
      isLoading: false,
      error: null,
    );
  } else if (action is SignInFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  } else if (action is SignOutAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  } else if (action is SignOutSuccessAction) {
    return AuthState.initial();
  } else if (action is SignOutFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  } else if (action is UpdateUserAction) {
    return state.copyWith(
      user: action.user,
      error: null,
    );
  }
  return state;
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
    final newState = state.copyWith(
      petIds: action.petIds,
      isLoading: false,
      error: null,
    );
    return newState.initializeActivePet();
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