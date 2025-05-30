import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_peeves/providers/auth_provider.dart';
import 'package:pet_peeves/routes/app_router.dart';
import 'package:pet_peeves/services/pet_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<FeatureHighlight> _features = [
    FeatureHighlight(
      title: 'Track Pet Health',
      description: 'Monitor your pet\'s health metrics and get timely reminders for check-ups.',
      icon: Icons.favorite,
      color: Colors.red,
    ),
    FeatureHighlight(
      title: 'Food & Diet',
      description: 'Keep track of feeding schedules and dietary requirements.',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    FeatureHighlight(
      title: 'Activity Timeline',
      description: 'View your pet\'s daily activities and important events.',
      icon: Icons.history,
      color: Colors.blue,
    ),
    FeatureHighlight(
      title: 'Measurements',
      description: 'Track growth and weight changes over time.',
      icon: Icons.straighten,
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();
    
    if (success && mounted) {
      final hasPets = await authProvider.hasPets();
      final userId = authProvider.user?.uid;
      final petService = PetService();
      if (hasPets) {
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.onboarding,
          arguments: {
            'userId': userId,
            'petService': petService,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _features.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _FeaturePage(
                  feature: _features[index],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _features.length,
                      (index) => _PageIndicator(
                        isActive: index == _currentPage,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: auth.isLoading
                          ? const CircularProgressIndicator()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://www.google.com/favicon.ico',
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text('Sign in with Google'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePage extends StatelessWidget {
  final FeatureHighlight feature;

  const _FeaturePage({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            feature.icon,
            size: 80,
            color: feature.color,
          ),
          const SizedBox(height: 24),
          Text(
            feature.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            feature.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;

  const _PageIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.3),
      ),
    );
  }
}

class FeatureHighlight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  FeatureHighlight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
} 