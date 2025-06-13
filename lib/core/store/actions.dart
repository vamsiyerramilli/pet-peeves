import 'app_state.dart';
import '../../features/auth/models/user_model.dart';

// Auth Actions
class SignInAction {
  final bool isLoading;
  SignInAction({this.isLoading = true});
}

class SignInSuccessAction {
  final UserModel user;
  SignInSuccessAction(this.user);
}

class SignInFailureAction {
  final String error;
  SignInFailureAction(this.error);
}

class SignOutAction {}

class SignOutSuccessAction {}

class SignOutFailureAction {
  final String error;
  SignOutFailureAction(this.error);
}

class UpdateUserAction {
  final UserModel user;
  UpdateUserAction(this.user);
}

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