import 'package:redux/redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart';
import 'actions.dart';
import '../../features/food/store/food_middleware.dart';
import '../../features/food/store/food_tracking_middleware.dart';
import '../../features/food/services/food_service.dart';
import '../../features/food/store/food_actions.dart';
import '../../features/measurements/store/measurement_middleware.dart';
import '../../features/measurements/services/measurement_service.dart';
import '../../features/measurements/store/measurement_actions.dart';

List<Middleware<AppState>> createMiddleware() {
  final firestore = FirebaseFirestore.instance;
  final foodService = FoodService(firestore);
  final measurementService = MeasurementService(firestore);

  return [
    // Ensure pets still load after authentication
    TypedMiddleware<AppState, LoadPetsAction>(_loadPets),

    // When the user object is stored in Redux, kick off pet loading
    TypedMiddleware<AppState, UpdateUserAction>(_handleUserUpdate),

    ...createFoodMiddleware(foodService),
    ...createFoodTrackingMiddleware(foodService),
    ...createMeasurementMiddleware(measurementService),
  ];
}

void _loadPets(Store<AppState> store, LoadPetsAction action, NextDispatcher next) async {
  next(action);

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(action.userId)
        .collection('pets')
        .get();

    final petIds = snapshot.docs.map((doc) => doc.id).toList();
    store.dispatch(LoadPetsSuccessAction(petIds));
  } catch (e) {
    store.dispatch(LoadPetsFailureAction(e.toString()));
  }
}

void _handleUserUpdate(Store<AppState> store, UpdateUserAction action, NextDispatcher next) {
  print('HANDLE_USER_UPDATE: called for user ' + action.user.uid);
  next(action);

  // If we have a valid user ID we can fetch their pets immediately
  final uid = action.user.uid;
  if (uid.isNotEmpty) {
    store.dispatch(LoadPetsAction(uid));
    store.dispatch(LoadFoodsAction(uid)); // Load foods on auth success
    store.dispatch(LoadMeasurementsAction(uid)); // Load measurements on auth success
  }
} 