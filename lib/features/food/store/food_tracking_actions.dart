import '../models/food_tracking_entry.dart';

// Load entries
class LoadFoodTrackingEntries {
  final String petId;
  
  LoadFoodTrackingEntries(this.petId);
}

class LoadFoodTrackingEntriesSuccess {
  final String petId;
  final List<FoodTrackingEntry> entries;
  
  LoadFoodTrackingEntriesSuccess(this.petId, this.entries);
}

class LoadFoodTrackingEntriesFailure {
  final String petId;
  final String error;
  
  LoadFoodTrackingEntriesFailure(this.petId, this.error);
}

// Add entry
class AddFoodTrackingEntry {
  final String petId;
  final FoodTrackingEntry entry;
  final bool optimistic;
  
  AddFoodTrackingEntry(this.petId, this.entry, {this.optimistic = false});
}

class AddFoodTrackingEntrySuccess {
  final String petId;
  final FoodTrackingEntry entry;
  final bool wasOptimistic;
  
  AddFoodTrackingEntrySuccess(this.petId, this.entry, {this.wasOptimistic = false});
}

class AddFoodTrackingEntryFailure {
  final String petId;
  final String error;
  final bool wasOptimistic;
  
  AddFoodTrackingEntryFailure(this.petId, this.error, {this.wasOptimistic = false});
}

// Update entry
class UpdateFoodTrackingEntry {
  final String petId;
  final FoodTrackingEntry entry;
  final bool optimistic;
  
  UpdateFoodTrackingEntry(this.petId, this.entry, {this.optimistic = false});
}

class UpdateFoodTrackingEntrySuccess {
  final String petId;
  final FoodTrackingEntry entry;
  final bool wasOptimistic;
  
  UpdateFoodTrackingEntrySuccess(this.petId, this.entry, {this.wasOptimistic = false});
}

class UpdateFoodTrackingEntryFailure {
  final String petId;
  final String error;
  final bool wasOptimistic;
  
  UpdateFoodTrackingEntryFailure(this.petId, this.error, {this.wasOptimistic = false});
}

// Delete entry
class DeleteFoodTrackingEntry {
  final String petId;
  final String entryId;
  final bool optimistic;
  
  DeleteFoodTrackingEntry(this.petId, this.entryId, {this.optimistic = false});
}

class DeleteFoodTrackingEntrySuccess {
  final String petId;
  final String entryId;
  final bool wasOptimistic;
  
  DeleteFoodTrackingEntrySuccess(this.petId, this.entryId, {this.wasOptimistic = false});
}

class DeleteFoodTrackingEntryFailure {
  final String petId;
  final String error;
  final bool wasOptimistic;
  
  DeleteFoodTrackingEntryFailure(this.petId, this.error, {this.wasOptimistic = false});
}

// Sync status
class SetFoodTrackingEntrySyncStatus {
  final String petId;
  final String entryId;
  final bool isPending;
  
  SetFoodTrackingEntrySyncStatus(this.petId, this.entryId, this.isPending);
}

// Clear Error Action
class ClearFoodTrackingError {
  final String petId;
  
  ClearFoodTrackingError(this.petId);
} 