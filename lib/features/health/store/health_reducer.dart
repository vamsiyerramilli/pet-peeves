import 'health_state.dart';
import 'health_actions.dart';

HealthState healthReducer(HealthState state, dynamic action) {
  if (action is LoadHealthEntriesAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  
  if (action is LoadHealthEntriesSuccessAction) {
    // For initial load, replace all entries
    print('Reducer: Loaded ${action.entries.length} health entries');
    return state.copyWith(
      entries: action.entries,
      isLoading: false,
      error: null,
    );
  }
  
  if (action is LoadHealthEntriesFailureAction) {
    print('Reducer: Failed to load health entries: ${action.error}');
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }
  
  if (action is AddHealthEntryAction) {
    // Optimistically add the entry to the state
    final updatedEntries = [...state.entries, action.entry];
    return state.copyWith(
      entries: updatedEntries,
      error: null,
    );
  }
  
  if (action is AddHealthEntrySuccessAction) {
    // Replace the temporary entry with the server-returned one
    final updatedEntries = state.entries.map((entry) {
      if (entry.id == action.entry.id) {
        return action.entry;
      }
      return entry;
    }).toList();
    
    print('Reducer: Successfully added health entry: ${action.entry.id}');
    return state.copyWith(
      entries: updatedEntries,
      error: null,
    );
  }
  
  if (action is AddHealthEntryFailureAction) {
    // Remove the failed entry and show error
    final updatedEntries = state.entries.where((entry) => entry.id != action.entry.id).toList();
    
    print('Reducer: Failed to add health entry: ${action.error}');
    return state.copyWith(
      entries: updatedEntries,
      error: action.error,
    );
  }
  
  if (action is EditHealthEntryAction) {
    // Optimistically update the entry
    final updatedEntries = state.entries.map((entry) {
      if (entry.id == action.entryId) {
        return action.updatedEntry;
      }
      return entry;
    }).toList();
    
    return state.copyWith(
      entries: updatedEntries,
      error: null,
    );
  }
  
  if (action is EditHealthEntrySuccessAction) {
    // Replace the temporary entry with the server-returned one
    final updatedEntries = state.entries.map((entry) {
      if (entry.id == action.entry.id) {
        return action.entry;
      }
      return entry;
    }).toList();
    
    print('Reducer: Successfully edited health entry: ${action.entry.id}');
    return state.copyWith(
      entries: updatedEntries,
      error: null,
    );
  }
  
  if (action is EditHealthEntryFailureAction) {
    // Restore the original entry and show error
    final updatedEntries = state.entries.map((entry) {
      if (entry.id == action.entryId) {
        return action.originalEntry;
      }
      return entry;
    }).toList();
    
    print('Reducer: Failed to edit health entry: ${action.error}');
    return state.copyWith(
      entries: updatedEntries,
      error: action.error,
    );
  }
  
  if (action is DeleteHealthEntryAction) {
    // Optimistically remove the entry
    final updatedEntries = state.entries.where((entry) => entry.id != action.entryId).toList();
    
    return state.copyWith(
      entries: updatedEntries,
      error: null,
    );
  }
  
  if (action is DeleteHealthEntrySuccessAction) {
    // Entry already removed optimistically, just clear any error
    print('Reducer: Successfully deleted health entry: ${action.entryId}');
    return state.copyWith(error: null);
  }
  
  if (action is DeleteHealthEntryFailureAction) {
    // Restore the deleted entry and show error
    // Note: We would need to store the deleted entry temporarily to restore it
    // For now, we'll just show the error and let the user retry
    print('Reducer: Failed to delete health entry: ${action.error}');
    return state.copyWith(error: action.error);
  }
  
  if (action is SyncHealthEntriesAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  
  if (action is SyncHealthEntriesSuccessAction) {
    print('Reducer: Health entries synced at: ${action.lastSyncedAt}');
    return state.copyWith(
      isLoading: false,
      lastSyncedAt: action.lastSyncedAt,
      error: null,
    );
  }
  
  if (action is SyncHealthEntriesFailureAction) {
    print('Reducer: Failed to sync health entries: ${action.error}');
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }
  
  if (action is ClearHealthErrorAction) {
    return state.copyWith(error: null);
  }
  
  if (action is ClearHealthEntriesAction) {
    print('Reducer: Clearing all health entries');
    return HealthState.initial();
  }
  
  // Advanced Querying Actions
  if (action is LoadHealthEntriesInDateRangeAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  
  if (action is LoadHealthEntriesInDateRangeSuccessAction) {
    // Merge the new entries with existing ones, avoiding duplicates
    final existingIds = state.entries.map((e) => e.id).toSet();
    final newEntries = action.entries.where((e) => !existingIds.contains(e.id)).toList();
    final updatedEntries = [...state.entries, ...newEntries];
    
    print('Reducer: Loaded ${action.entries.length} health entries in date range, merged ${newEntries.length} new entries');
    return state.copyWith(
      entries: updatedEntries,
      isLoading: false,
      error: null,
    );
  }
  
  if (action is LoadHealthEntriesInDateRangeFailureAction) {
    print('Reducer: Failed to load health entries in date range: ${action.error}');
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }
  
  if (action is LoadTemperatureEntriesAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  
  if (action is LoadTemperatureEntriesSuccessAction) {
    // Merge the new entries with existing ones, avoiding duplicates
    final existingIds = state.entries.map((e) => e.id).toSet();
    final newEntries = action.entries.where((e) => !existingIds.contains(e.id)).toList();
    final updatedEntries = [...state.entries, ...newEntries];
    
    print('Reducer: Loaded ${action.entries.length} temperature entries, merged ${newEntries.length} new entries');
    return state.copyWith(
      entries: updatedEntries,
      isLoading: false,
      error: null,
    );
  }
  
  if (action is LoadTemperatureEntriesFailureAction) {
    print('Reducer: Failed to load temperature entries: ${action.error}');
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }
  
  if (action is LoadFileEntriesAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  
  if (action is LoadFileEntriesSuccessAction) {
    // Merge the new entries with existing ones, avoiding duplicates
    final existingIds = state.entries.map((e) => e.id).toSet();
    final newEntries = action.entries.where((e) => !existingIds.contains(e.id)).toList();
    final updatedEntries = [...state.entries, ...newEntries];
    
    print('Reducer: Loaded ${action.entries.length} file entries, merged ${newEntries.length} new entries');
    return state.copyWith(
      entries: updatedEntries,
      isLoading: false,
      error: null,
    );
  }
  
  if (action is LoadFileEntriesFailureAction) {
    print('Reducer: Failed to load file entries: ${action.error}');
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }
  
  if (action is SearchHealthEntriesAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  
  if (action is SearchHealthEntriesSuccessAction) {
    // For search results, we might want to replace all entries or just add to them
    // For now, we'll add them to existing entries to maintain consistency
    final existingIds = state.entries.map((e) => e.id).toSet();
    final newEntries = action.entries.where((e) => !existingIds.contains(e.id)).toList();
    final updatedEntries = [...state.entries, ...newEntries];
    
    print('Reducer: Found ${action.entries.length} health entries matching search, merged ${newEntries.length} new entries');
    return state.copyWith(
      entries: updatedEntries,
      isLoading: false,
      error: null,
    );
  }
  
  if (action is SearchHealthEntriesFailureAction) {
    print('Reducer: Failed to search health entries: ${action.error}');
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }
  
  if (action is LoadHealthEntryStatsAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  
  if (action is LoadHealthEntryStatsSuccessAction) {
    // Stats don't affect the entries list, just clear loading state
    print('Reducer: Loaded health entry stats: ${action.stats}');
    return state.copyWith(
      isLoading: false,
      error: null,
    );
  }
  
  if (action is LoadHealthEntryStatsFailureAction) {
    print('Reducer: Failed to load health entry stats: ${action.error}');
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }
  
  // Return unchanged state for unknown actions
  return state;
} 