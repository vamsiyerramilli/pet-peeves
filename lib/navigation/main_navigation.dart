import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/dashboard/dashboard_screen.dart';
import 'package:pet_peeves/screens/logs/logs_screen.dart';
import 'package:pet_peeves/screens/pet_info/pet_profile_screen.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:pet_peeves/widgets/main_screen_wrapper.dart';

class MainNavigation extends StatefulWidget {
  final Pet pet;
  final PetService petService;

  const MainNavigation({
    super.key,
    required this.pet,
    required this.petService,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MainScreenWrapper(
            pet: widget.pet,
            petService: widget.petService,
            child: DashboardScreen(
              pet: widget.pet,
              petService: widget.petService,
            ),
          ),
          MainScreenWrapper(
            pet: widget.pet,
            petService: widget.petService,
            child: LogsScreen(
              pet: widget.pet,
              petService: widget.petService,
            ),
          ),
          MainScreenWrapper(
            pet: widget.pet,
            petService: widget.petService,
            showFab: false,
            child: PetProfileScreen(
              pet: widget.pet,
              petService: widget.petService,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Logs',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Pet Info',
          ),
        ],
      ),
    );
  }
} 