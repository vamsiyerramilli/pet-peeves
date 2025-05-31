import 'package:redux/redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart';
import 'actions.dart';

List<Middleware<AppState>> createMiddleware() {
  return [
    TypedMiddleware<AppState, LoadPetsAction>(_loadPets),
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
    store.dispatch(SetPetIdsAction(petIds));
    
    // Set first pet as active if none is selected
    if (petIds.isNotEmpty && store.state.pets.activePetId == null) {
      store.dispatch(SetActivePetAction(petIds.first));
    }
  } catch (e) {
    store.dispatch(LoadPetsFailureAction(e.toString()));
  }
} 