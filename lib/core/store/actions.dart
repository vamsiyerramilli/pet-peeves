import 'app_state.dart';

// Navigation Actions
class SetActiveTabAction {
  final AppTab tab;
  SetActiveTabAction(this.tab);
}

class UpdateScrollPositionAction {
  final AppTab tab;
  final double position;
  UpdateScrollPositionAction(this.tab, this.position);
}

// Pet Actions
class SetPetIdsAction {
  final List<String> petIds;
  SetPetIdsAction(this.petIds);
}

class LoadPetsAction {
  final String userId;
  LoadPetsAction(this.userId);
}

class LoadPetsSuccessAction {
  final List<String> petIds;
  LoadPetsSuccessAction(this.petIds);
}

class LoadPetsFailureAction {
  final String error;
  LoadPetsFailureAction(this.error);
}

class SetActivePetAction {
  final String petId;
  SetActivePetAction(this.petId);
}

class ClearActivePetAction {}

class RefreshPetsAction {} 