import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'firebase_options.dart';
import 'core/store/app_state.dart';
import 'core/store/actions.dart';
import 'core/store/reducers.dart';
import 'core/store/middleware.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_layout.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/pets/screens/home_screen.dart';
import 'features/pets/screens/logs_screen.dart';
import 'features/pets/screens/pet_info_screen.dart';
import 'features/pets/screens/pet_onboarding_screen.dart';
import 'features/auth/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: createMiddleware(),
  );

  // Initialize auth state from Firebase
  _initializeAuthState(store);

  runApp(MyApp(store: store));
}

void _initializeAuthState(Store<AppState> store) {
  final authService = AuthService();
  
  // Listen to Firebase auth changes and update Redux
  authService.authStateChanges.listen((firebaseUser) async {
    if (firebaseUser != null) {
      try {
        // Get or create user profile
        UserModel? userModel = await authService.getUserProfile(firebaseUser.uid);
        
        if (userModel == null) {
          // Create new user profile
          userModel = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            profilePhotoUrl: firebaseUser.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await authService.updateUserProfile(userModel);
        }
        
        // Set user in auth state (stops loading)
        store.dispatch(SignInSuccessAction(userModel));
        
        // Load pets separately
        store.dispatch(LoadPetsAction(userModel.uid));
        
      } catch (e) {
        store.dispatch(SignInFailureAction(e.toString()));
      }
    } else {
      // User signed out
      store.dispatch(SignOutSuccessAction());
    }
  });
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Pet Peeves',
        theme: AppTheme.lightTheme,
        home: StoreConnector<AppState, _ViewModel>(
          distinct: true,
          converter: (store) => _ViewModel.fromStore(store),
          builder: (context, vm) {
            // Show loading while auth is initializing
            if (vm.isLoading || vm.petsLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Show login if no user
            if (vm.user == null) {
              return const LoginScreen();
            }

            // Show pet onboarding if user has no pets
            if (vm.petIds.isEmpty) {
              return PetOnboardingScreen(userId: vm.user!.uid);
            }

            // Show main app if user has pets
            return AppLayout(
              tabViews: {
                AppTab.home: const HomeScreen(),
                AppTab.logs: const LogsScreen(),
                AppTab.petInfo: const PetInfoScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final UserModel? user;
  final List<String> petIds;
  final bool petsLoading;

  _ViewModel({
    required this.isLoading,
    this.user,
    required this.petIds,
    required this.petsLoading,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isLoading: store.state.auth.isLoading,
      user: store.state.auth.user,
      petIds: store.state.pets.petIds,
      petsLoading: store.state.pets.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ViewModel &&
        other.isLoading == isLoading &&
        other.user?.uid == user?.uid &&
        other.petIds.length == petIds.length &&
        other.petsLoading == petsLoading;
  }

  @override
  int get hashCode => Object.hash(isLoading, user?.uid, petIds.length, petsLoading);
} 