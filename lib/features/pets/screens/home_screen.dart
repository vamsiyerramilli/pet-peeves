import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Coming Soon',
              style: AppTheme.headingStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'User ID: $userId',
              style: AppTheme.bodyStyle,
            ),
          ],
        ),
      ),
    );
  }
} 