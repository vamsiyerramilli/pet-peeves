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

  runApp(MyApp(store: store));
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
        home: StreamBuilder(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final user = snapshot.data;
            if (user == null) {
              return const LoginScreen();
            }

            // Load pets when user is logged in
            WidgetsBinding.instance.addPostFrameCallback((_) {
              store.dispatch(LoadPetsAction(user.uid));
            });

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