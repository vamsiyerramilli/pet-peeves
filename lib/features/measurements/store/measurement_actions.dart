import 'package:redux/redux.dart';
import '../models/measurement_entry.dart';

// Loading actions
class LoadMeasurementsAction {
  final String petId;
  LoadMeasurementsAction(this.petId);
}

class LoadMeasurementsSuccessAction {
  final String petId;
  final List<MeasurementEntry> entries;
  LoadMeasurementsSuccessAction(this.petId, this.entries);
}

class LoadMeasurementsFailureAction {
  final String error;
  final String petId;
  LoadMeasurementsFailureAction(this.error, this.petId);
}

// Adding actions
class AddMeasurementAction {
  final String petId;
  final MeasurementEntry entry;
  final bool optimistic;
  AddMeasurementAction(this.petId, this.entry, {this.optimistic = false});
}

class AddMeasurementSuccessAction {
  final String petId;
  final MeasurementEntry entry;
  final bool wasOptimistic;
  AddMeasurementSuccessAction(this.petId, this.entry, {this.wasOptimistic = false});
}

class AddMeasurementFailureAction {
  final String error;
  final MeasurementEntry entry;
  AddMeasurementFailureAction(this.error, this.entry);
}

// Editing actions
class EditMeasurementAction {
  final String petId;
  final MeasurementEntry entry;
  final bool optimistic;
  EditMeasurementAction(this.petId, this.entry, {this.optimistic = false});
}

class EditMeasurementSuccessAction {
  final String petId;
  final MeasurementEntry entry;
  final bool wasOptimistic;
  EditMeasurementSuccessAction(this.petId, this.entry, {this.wasOptimistic = false});
}

class EditMeasurementFailureAction {
  final String error;
  final MeasurementEntry entry;
  EditMeasurementFailureAction(this.error, this.entry);
}

// Deleting actions
class DeleteMeasurementAction {
  final String petId;
  final String entryId;
  final bool optimistic;
  DeleteMeasurementAction(this.petId, this.entryId, {this.optimistic = false});
}

class DeleteMeasurementSuccessAction {
  final String petId;
  final String entryId;
  final bool wasOptimistic;
  DeleteMeasurementSuccessAction(this.petId, this.entryId, {this.wasOptimistic = false});
}

class DeleteMeasurementFailureAction {
  final String error;
  final String entryId;
  DeleteMeasurementFailureAction(this.error, this.entryId);
}

// Offline sync actions
class SyncMeasurementsAction {
  final String petId;
  SyncMeasurementsAction(this.petId);
}

class SyncMeasurementsSuccessAction {
  final String petId;
  final List<MeasurementEntry> entries;
  SyncMeasurementsSuccessAction(this.petId, this.entries);
}

class SyncMeasurementsFailureAction {
  final String error;
  final String petId;
  SyncMeasurementsFailureAction(this.error, this.petId);
} 