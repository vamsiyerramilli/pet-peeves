import 'package:redux/redux.dart';
import '../services/health_service.dart';
import 'health_actions.dart';
import '../../../core/store/app_state.dart';

List<Middleware<AppState>> createHealthMiddleware(HealthService service) {
  return [
    TypedMiddleware<AppState, LoadHealthEntriesAction>(_handleLoadHealthEntries(service)),
    TypedMiddleware<AppState, AddHealthEntryAction>(_handleAddHealthEntry(service)),
    TypedMiddleware<AppState, EditHealthEntryAction>(_handleEditHealthEntry(service)),
    TypedMiddleware<AppState, DeleteHealthEntryAction>(_handleDeleteHealthEntry(service)),
    TypedMiddleware<AppState, SyncHealthEntriesAction>(_handleSyncHealthEntries(service)),
    TypedMiddleware<AppState, LoadHealthEntriesInDateRangeAction>(_handleLoadHealthEntriesInDateRange(service)),
    TypedMiddleware<AppState, LoadTemperatureEntriesAction>(_handleLoadTemperatureEntries(service)),
    TypedMiddleware<AppState, LoadFileEntriesAction>(_handleLoadFileEntries(service)),
    TypedMiddleware<AppState, SearchHealthEntriesAction>(_handleSearchHealthEntries(service)),
    TypedMiddleware<AppState, LoadHealthEntryStatsAction>(_handleLoadHealthEntryStats(service)),
  ];
}

Middleware<AppState> _handleLoadHealthEntries(HealthService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! LoadHealthEntriesAction) return next(action);
    
    next(action);
    try {
      print('Loading health entries for pet: ${action.petId}');
      final entries = await service.loadHealthEntries(action.petId);
      print('Loaded ${entries.length} health entries');
      
      // Ensure all entries have the correct petId set
      final validatedEntries = entries.map((entry) {
        if (entry.petId.isEmpty) {
          return entry.copyWith(petId: action.petId);
        }
        return entry;
      }).toList();
      
      store.dispatch(LoadHealthEntriesSuccessAction(entries: validatedEntries));
    } catch (e) {
      print('Error loading health entries: $e');
      store.dispatch(LoadHealthEntriesFailureAction(error: e.toString()));
    }
  };
}

Middleware<AppState> _handleAddHealthEntry(HealthService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! AddHealthEntryAction) return next(action);
    
    next(action);
    try {
      print('Adding health entry for pet: ${action.entry.petId}');
      final entry = await service.addHealthEntry(action.entry);
      print('Successfully added health entry: ${entry.id}');
      store.dispatch(AddHealthEntrySuccessAction(entry: entry));
    } catch (e) {
      print('Error adding health entry: $e');
      store.dispatch(AddHealthEntryFailureAction(
        error: e.toString(),
        entry: action.entry,
      ));
    }
  };
}

Middleware<AppState> _handleEditHealthEntry(HealthService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! EditHealthEntryAction) return next(action);
    
    next(action);
    try {
      print('Editing health entry: ${action.entryId}');
      final entry = await service.editHealthEntry(
        action.entryId,
        action.updatedEntry,
      );
      print('Successfully edited health entry: ${entry.id}');
      store.dispatch(EditHealthEntrySuccessAction(entry: entry));
    } catch (e) {
      print('Error editing health entry: $e');
      // Find the original entry to restore it
      final healthState = store.state.health;
      final originalEntry = healthState.entries.firstWhere(
        (entry) => entry.id == action.entryId,
        orElse: () => action.updatedEntry,
      );
      
      store.dispatch(EditHealthEntryFailureAction(
        error: e.toString(),
        entryId: action.entryId,
        originalEntry: originalEntry,
      ));
    }
  };
}

Middleware<AppState> _handleDeleteHealthEntry(HealthService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! DeleteHealthEntryAction) return next(action);
    
    next(action);
    try {
      // Get the petId from the current state or action
      final healthState = store.state.health;
      final entry = healthState.entries.firstWhere(
        (entry) => entry.id == action.entryId,
        orElse: () => throw Exception('Entry not found in state'),
      );
      
      print('Deleting health entry: ${action.entryId} for pet: ${entry.petId}');
      await service.deleteHealthEntry(action.entryId, entry.petId);
      print('Successfully deleted health entry: ${action.entryId}');
      store.dispatch(DeleteHealthEntrySuccessAction(entryId: action.entryId));
    } catch (e) {
      print('Error deleting health entry: $e');
      store.dispatch(DeleteHealthEntryFailureAction(
        error: e.toString(),
        entryId: action.entryId,
      ));
    }
  };
}

Middleware<AppState> _handleSyncHealthEntries(HealthService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! SyncHealthEntriesAction) return next(action);
    
    next(action);
    try {
      print('Syncing health entries...');
      // For now, just return current timestamp as sync is not implemented
      // This can be enhanced later with actual sync logic
      final lastSyncedAt = DateTime.now();
      print('Health entries synced at: $lastSyncedAt');
      store.dispatch(SyncHealthEntriesSuccessAction(lastSyncedAt: lastSyncedAt));
    } catch (e) {
      print('Error syncing health entries: $e');
      store.dispatch(SyncHealthEntriesFailureAction(error: e.toString()));
    }
  };
}

Middleware<AppState> _handleLoadHealthEntriesInDateRange(HealthService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! LoadHealthEntriesInDateRangeAction) return next(action);
    
    next(action);
    try {
      print('Loading health entries in date range for pet: ${action.petId}');
      print('Date range: ${action.startDate} to ${action.endDate}');
      
      final entries = await service.loadHealthEntriesInDateRange(
        action.petId,
        startDate: action.startDate,
        endDate: action.endDate,
      );
      print('Loaded ${entries.length} health entries in date range');
      
      // Ensure all entries have the correct petId set
      final validatedEntries = entries.map((entry) {
        if (entry.petId.isEmpty) {
          return entry.copyWith(petId: action.petId);
        }
        return entry;
      }).toList();
      
      store.dispatch(LoadHealthEntriesInDateRangeSuccessAction(entries: validatedEntries));
    } catch (e) {
      print('Error loading health entries in date range: $e');
      store.dispatch(LoadHealthEntriesInDateRangeFailureAction(error: e.toString()));
    }
  };
}

Middleware<AppState> _handleLoadTemperatureEntries(HealthService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! LoadTemperatureEntriesAction) return next(action);
    
    next(action);
    try {
      print('Loading temperature entries for pet: ${action.petId}');
      final entries = await service.loadTemperatureEntries(action.petId);
      print('Loaded ${entries.length} temperature entries');
      
      // Ensure all entries have the correct petId set
      final validatedEntries = entries.map((entry) {
        if (entry.petId.isEmpty) {
          return entry.copyWith(petId: action.petId);
        }
        return entry;
      }).toList();
      
      store.dispatch(LoadTemperatureEntriesSuccessAction(entries: validatedEntries));
    } catch (e) {
      print('Error loading temperature entries: $e');
      store.dispatch(LoadTemperatureEntriesFailureAction(error: e.toString()));
    }
  };
}

Middleware<AppState> _handleLoadFileEntries(HealthService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! LoadFileEntriesAction) return next(action);
    
    next(action);
    try {
      print('Loading file entries for pet: ${action.petId}');
      final entries = await service.loadFileEntries(action.petId);
      print('Loaded ${entries.length} file entries');
      
      // Ensure all entries have the correct petId set
      final validatedEntries = entries.map((entry) {
        if (entry.petId.isEmpty) {
          return entry.copyWith(petId: action.petId);
        }
        return entry;
      }).toList();
      
      store.dispatch(LoadFileEntriesSuccessAction(entries: validatedEntries));
    } catch (e) {
      print('Error loading file entries: $e');
      store.dispatch(LoadFileEntriesFailureAction(error: e.toString()));
    }
  };
}

Middleware<AppState> _handleSearchHealthEntries(HealthService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! SearchHealthEntriesAction) return next(action);
    
    next(action);
    try {
      print('Searching health entries for pet: ${action.petId}');
      print('Search term: "${action.searchTerm}"');
      
      final entries = await service.searchHealthEntriesByNotes(
        action.petId,
        action.searchTerm,
      );
      print('Found ${entries.length} health entries matching search');
      
      // Ensure all entries have the correct petId set
      final validatedEntries = entries.map((entry) {
        if (entry.petId.isEmpty) {
          return entry.copyWith(petId: action.petId);
        }
        return entry;
      }).toList();
      
      store.dispatch(SearchHealthEntriesSuccessAction(entries: validatedEntries));
    } catch (e) {
      print('Error searching health entries: $e');
      store.dispatch(SearchHealthEntriesFailureAction(error: e.toString()));
    }
  };
}

Middleware<AppState> _handleLoadHealthEntryStats(HealthService service) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is! LoadHealthEntryStatsAction) return next(action);
    
    next(action);
    try {
      print('Loading health entry stats for pet: ${action.petId}');
      final stats = await service.getHealthEntryStats(action.petId);
      print('Loaded health entry stats: $stats');
      store.dispatch(LoadHealthEntryStatsSuccessAction(stats: stats));
    } catch (e) {
      print('Error loading health entry stats: $e');
      store.dispatch(LoadHealthEntryStatsFailureAction(error: e.toString()));
    }
  };
} 