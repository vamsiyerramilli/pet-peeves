import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../../../core/store/actions.dart';
import '../../../core/store/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSignIn() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Dispatch loading action to Redux
    store.dispatch(SignInAction(isLoading: true));

    try {
      // Just perform the Firebase sign in
      // The auth state listener in main.dart will handle updating Redux
      await _authService.signInWithFirebase();
      
      // No manual navigation - let Redux state changes handle it
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      // Dispatch error to Redux
      store.dispatch(SignInFailureAction(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo
              const Icon(
                Icons.pets,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              
              // Welcome Text
              Text(
                'Welcome to Pet Peeves',
                style: AppTheme.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your pet\'s health companion',
                style: AppTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Sign In Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSignIn,
                style: AppTheme.primaryButtonStyle,
                icon: SvgPicture.asset(
                  'assets/google_logo.svg',
                  height: 24,
                ),
                label: Text(
                  _isLoading ? 'Signing in...' : 'Continue with Google',
                  style: AppTheme.buttonTextStyle,
                ),
              ),
              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Terms and Privacy
              const SizedBox(height: 24),
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 