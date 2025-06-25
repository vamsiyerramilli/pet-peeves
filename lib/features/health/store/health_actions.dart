import 'package:meta/meta.dart';
import '../models/health_entry.dart';

// Load Health Entries Actions
@immutable
class LoadHealthEntriesAction {
  final String petId;
  
  const LoadHealthEntriesAction({required this.petId});
}

@immutable
class LoadHealthEntriesSuccessAction {
  final List<HealthEntry> entries;
  
  const LoadHealthEntriesSuccessAction({required this.entries});
}

@immutable
class LoadHealthEntriesFailureAction {
  final String error;
  
  const LoadHealthEntriesFailureAction({required this.error});
}

// Add Health Entry Actions
@immutable
class AddHealthEntryAction {
  final HealthEntry entry;
  
  const AddHealthEntryAction({required this.entry});
}

@immutable
class AddHealthEntrySuccessAction {
  final HealthEntry entry;
  
  const AddHealthEntrySuccessAction({required this.entry});
}

@immutable
class AddHealthEntryFailureAction {
  final String error;
  final HealthEntry entry;
  
  const AddHealthEntryFailureAction({
    required this.error,
    required this.entry,
  });
}

// Edit Health Entry Actions
@immutable
class EditHealthEntryAction {
  final String entryId;
  final HealthEntry updatedEntry;
  
  const EditHealthEntryAction({
    required this.entryId,
    required this.updatedEntry,
  });
}

@immutable
class EditHealthEntrySuccessAction {
  final HealthEntry entry;
  
  const EditHealthEntrySuccessAction({required this.entry});
}

@immutable
class EditHealthEntryFailureAction {
  final String error;
  final String entryId;
  final HealthEntry originalEntry;
  
  const EditHealthEntryFailureAction({
    required this.error,
    required this.entryId,
    required this.originalEntry,
  });
}

// Delete Health Entry Actions
@immutable
class DeleteHealthEntryAction {
  final String entryId;
  
  const DeleteHealthEntryAction({required this.entryId});
}

@immutable
class DeleteHealthEntrySuccessAction {
  final String entryId;
  
  const DeleteHealthEntrySuccessAction({required this.entryId});
}

@immutable
class DeleteHealthEntryFailureAction {
  final String error;
  final String entryId;
  
  const DeleteHealthEntryFailureAction({
    required this.error,
    required this.entryId,
  });
}

// Sync Actions
@immutable
class SyncHealthEntriesAction {
  const SyncHealthEntriesAction();
}

@immutable
class SyncHealthEntriesSuccessAction {
  final DateTime lastSyncedAt;
  
  const SyncHealthEntriesSuccessAction({required this.lastSyncedAt});
}

@immutable
class SyncHealthEntriesFailureAction {
  final String error;
  
  const SyncHealthEntriesFailureAction({required this.error});
}

// Advanced Querying Actions
@immutable
class LoadHealthEntriesInDateRangeAction {
  final String petId;
  final DateTime? startDate;
  final DateTime? endDate;
  
  const LoadHealthEntriesInDateRangeAction({
    required this.petId,
    this.startDate,
    this.endDate,
  });
}

@immutable
class LoadHealthEntriesInDateRangeSuccessAction {
  final List<HealthEntry> entries;
  
  const LoadHealthEntriesInDateRangeSuccessAction({required this.entries});
}

@immutable
class LoadHealthEntriesInDateRangeFailureAction {
  final String error;
  
  const LoadHealthEntriesInDateRangeFailureAction({required this.error});
}

@immutable
class LoadTemperatureEntriesAction {
  final String petId;
  
  const LoadTemperatureEntriesAction({required this.petId});
}

@immutable
class LoadTemperatureEntriesSuccessAction {
  final List<HealthEntry> entries;
  
  const LoadTemperatureEntriesSuccessAction({required this.entries});
}

@immutable
class LoadTemperatureEntriesFailureAction {
  final String error;
  
  const LoadTemperatureEntriesFailureAction({required this.error});
}

@immutable
class LoadFileEntriesAction {
  final String petId;
  
  const LoadFileEntriesAction({required this.petId});
}

@immutable
class LoadFileEntriesSuccessAction {
  final List<HealthEntry> entries;
  
  const LoadFileEntriesSuccessAction({required this.entries});
}

@immutable
class LoadFileEntriesFailureAction {
  final String error;
  
  const LoadFileEntriesFailureAction({required this.error});
}

@immutable
class SearchHealthEntriesAction {
  final String petId;
  final String searchTerm;
  
  const SearchHealthEntriesAction({
    required this.petId,
    required this.searchTerm,
  });
}

@immutable
class SearchHealthEntriesSuccessAction {
  final List<HealthEntry> entries;
  
  const SearchHealthEntriesSuccessAction({required this.entries});
}

@immutable
class SearchHealthEntriesFailureAction {
  final String error;
  
  const SearchHealthEntriesFailureAction({required this.error});
}

@immutable
class LoadHealthEntryStatsAction {
  final String petId;
  
  const LoadHealthEntryStatsAction({required this.petId});
}

@immutable
class LoadHealthEntryStatsSuccessAction {
  final Map<String, dynamic> stats;
  
  const LoadHealthEntryStatsSuccessAction({required this.stats});
}

@immutable
class LoadHealthEntryStatsFailureAction {
  final String error;
  
  const LoadHealthEntryStatsFailureAction({required this.error});
}

// Clear Actions
@immutable
class ClearHealthErrorAction {
  const ClearHealthErrorAction();
}

@immutable
class ClearHealthEntriesAction {
  const ClearHealthEntriesAction();
} 