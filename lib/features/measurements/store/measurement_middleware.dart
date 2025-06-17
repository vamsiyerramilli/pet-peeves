import 'package:redux/redux.dart';
import '../services/measurement_service.dart';
import '../models/measurement_entry.dart';
import 'measurement_actions.dart';
import '../../../core/store/app_state.dart';

List<Middleware<AppState>> createMeasurementMiddleware(MeasurementService service) {
  return [
    TypedMiddleware<AppState, LoadMeasurementsAction>(_handleLoadMeasurements(service)),
    TypedMiddleware<AppState, AddMeasurementAction>(_handleAddMeasurement(service)),
    TypedMiddleware<AppState, EditMeasurementAction>(_handleEditMeasurement(service)),
    TypedMiddleware<AppState, DeleteMeasurementAction>(_handleDeleteMeasurement(service)),
    TypedMiddleware<AppState, SyncMeasurementsAction>(_handleSyncMeasurements(service)),
  ];
}

Middleware<AppState> _handleLoadMeasurements(MeasurementService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! LoadMeasurementsAction) return next(action);
    
    next(action);
    try {
      final entries = await service.loadMeasurements(action.petId);
      store.dispatch(LoadMeasurementsSuccessAction(action.petId, entries));
    } catch (e) {
      store.dispatch(LoadMeasurementsFailureAction(e.toString(), action.petId));
    }
  };
}

Middleware<AppState> _handleAddMeasurement(MeasurementService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! AddMeasurementAction) return next(action);
    
    next(action);
    try {
      if (action.optimistic) {
        final entry = await service.addMeasurement(action.petId, action.entry);
        store.dispatch(AddMeasurementSuccessAction(action.petId, entry, wasOptimistic: true));
      } else {
        final entry = await service.addMeasurement(action.petId, action.entry);
        store.dispatch(AddMeasurementSuccessAction(action.petId, entry));
      }
    } catch (e) {
      store.dispatch(AddMeasurementFailureAction(e.toString(), action.entry));
    }
  };
}

Middleware<AppState> _handleEditMeasurement(MeasurementService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! EditMeasurementAction) return next(action);
    
    next(action);
    try {
      if (action.optimistic) {
        final entry = await service.editMeasurement(action.petId, action.entry);
        store.dispatch(EditMeasurementSuccessAction(action.petId, entry, wasOptimistic: true));
      } else {
        final entry = await service.editMeasurement(action.petId, action.entry);
        store.dispatch(EditMeasurementSuccessAction(action.petId, entry));
      }
    } catch (e) {
      store.dispatch(EditMeasurementFailureAction(e.toString(), action.entry));
    }
  };
}

Middleware<AppState> _handleDeleteMeasurement(MeasurementService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! DeleteMeasurementAction) return next(action);
    
    next(action);
    try {
      if (action.optimistic) {
        await service.deleteMeasurement(action.petId, action.entryId);
        store.dispatch(DeleteMeasurementSuccessAction(action.petId, action.entryId, wasOptimistic: true));
      } else {
        await service.deleteMeasurement(action.petId, action.entryId);
        store.dispatch(DeleteMeasurementSuccessAction(action.petId, action.entryId));
      }
    } catch (e) {
      store.dispatch(DeleteMeasurementFailureAction(e.toString(), action.entryId));
    }
  };
}

Middleware<AppState> _handleSyncMeasurements(MeasurementService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! SyncMeasurementsAction) return next(action);
    
    next(action);
    try {
      final entries = await service.loadMeasurements(action.petId);
      store.dispatch(SyncMeasurementsSuccessAction(action.petId, entries));
    } catch (e) {
      store.dispatch(SyncMeasurementsFailureAction(e.toString(), action.petId));
    }
  };
} 