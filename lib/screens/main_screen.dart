import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/dashboard/dashboard_screen.dart';
import 'package:pet_peeves/widgets/main_navigation.dart';

class MainScreen extends StatefulWidget {
  final List<Pet> pets;

  const MainScreen({
    super.key,
    required this.pets,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(pets: widget.pets),
          const Center(child: Text('Logs Screen - Coming Soon')),
          const Center(child: Text('Pet Info Screen - Coming Soon')),
        ],
      ),
      bottomNavigationBar: MainNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}