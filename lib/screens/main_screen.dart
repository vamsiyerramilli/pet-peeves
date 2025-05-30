import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/dashboard/dashboard_screen.dart';
import 'package:pet_peeves/widgets/main_navigation.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:pet_peeves/screens/pet_info/pet_profile_screen.dart';

class MainScreen extends StatefulWidget {
  final List<Pet> pets;
  final PetService petService;

  const MainScreen({
    super.key,
    required this.pets,
    required this.petService,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late Pet _selectedPet;

  @override
  void initState() {
    super.initState();
    _selectedPet = widget.pets.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            pets: widget.pets,
            onPetSelected: (pet) {
              setState(() {
                _selectedPet = pet;
              });
            },
          ),
          const Center(child: Text('Logs Screen - Coming Soon')),
          PetProfileScreen(
            pet: _selectedPet,
            petService: widget.petService,
          ),
        ],
      ),
      bottomNavigationBar: MainNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}