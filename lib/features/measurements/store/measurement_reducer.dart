import 'package:redux/redux.dart';
import '../models/measurement_entry.dart';
import 'measurement_actions.dart';
import 'measurement_state.dart';

MeasurementState measurementReducer(MeasurementState state, dynamic action) {
  if (action is LoadMeasurementsAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is LoadMeasurementsSuccessAction) {
    return state.copyWith(
      entries: action.entries,
      isLoading: false,
      error: null,
    );
  }

  if (action is LoadMeasurementsFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  if (action is AddMeasurementAction) {
    if (action.optimistic) {
      return state.copyWith(
        entries: [...state.entries, action.entry],
        error: null,
      );
    }
    return state.copyWith(error: null);
  }

  if (action is AddMeasurementSuccessAction) {
    if (action.wasOptimistic) {
      return state.copyWith(
        entries: state.entries.map((entry) {
          if (entry.id == action.entry.id) {
            return action.entry;
          }
          return entry;
        }).toList(),
        error: null,
      );
    }
    return state.copyWith(
      entries: [...state.entries, action.entry],
      error: null,
    );
  }

  if (action is AddMeasurementFailureAction) {
    return state.copyWith(
      entries: state.entries.where((entry) => entry.id != action.entry.id).toList(),
      error: action.error,
    );
  }

  if (action is EditMeasurementAction) {
    if (action.optimistic) {
      return state.copyWith(
        entries: state.entries.map((entry) {
          if (entry.id == action.entry.id) {
            return action.entry;
          }
          return entry;
        }).toList(),
        error: null,
      );
    }
    return state.copyWith(error: null);
  }

  if (action is EditMeasurementSuccessAction) {
    if (action.wasOptimistic) {
      return state.copyWith(error: null);
    }
    return state.copyWith(
      entries: state.entries.map((entry) {
        if (entry.id == action.entry.id) {
          return action.entry;
        }
        return entry;
      }).toList(),
      error: null,
    );
  }

  if (action is EditMeasurementFailureAction) {
    return state.copyWith(
      entries: state.entries.map((entry) {
        if (entry.id == action.entry.id) {
          return entry; // Revert to original entry
        }
        return entry;
      }).toList(),
      error: action.error,
    );
  }

  if (action is DeleteMeasurementAction) {
    if (action.optimistic) {
      return state.copyWith(
        entries: state.entries.where((entry) => entry.id != action.entryId).toList(),
        error: null,
      );
    }
    return state.copyWith(error: null);
  }

  if (action is DeleteMeasurementSuccessAction) {
    if (action.wasOptimistic) {
      return state.copyWith(error: null);
    }
    return state.copyWith(
      entries: state.entries.where((entry) => entry.id != action.entryId).toList(),
      error: null,
    );
  }

  if (action is DeleteMeasurementFailureAction) {
    return state.copyWith(
      entries: [...state.entries], // Restore deleted entry
      error: action.error,
    );
  }

  if (action is SyncMeasurementsAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is SyncMeasurementsSuccessAction) {
    return state.copyWith(
      entries: action.entries,
      isLoading: false,
      error: null,
      lastSyncedAt: DateTime.now(),
    );
  }

  if (action is SyncMeasurementsFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  return state;
} 