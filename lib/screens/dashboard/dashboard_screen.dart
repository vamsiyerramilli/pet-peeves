import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/widgets/dashboard/dashboard_cards.dart';
import 'package:pet_peeves/widgets/pet_selector.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:pet_peeves/widgets/logs/add_log_bottom_sheet.dart';

class DashboardScreen extends StatefulWidget {
  final List<Pet> pets;
  final Function(Pet) onPetSelected;
  final PetService petService;

  const DashboardScreen({
    super.key,
    required this.pets,
    required this.onPetSelected,
    required this.petService,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Pet _selectedPet;
  late PetService _petService;

  @override
  void initState() {
    super.initState();
    _selectedPet = widget.pets.first;
    _petService = widget.petService;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPetSelected(_selectedPet);
    });
  }

  void _onPetSelected(Pet pet) {
    setState(() {
      _selectedPet = pet;
    });
    widget.onPetSelected(pet);
  }

  void _onAddFoodLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLogBottomSheet(
        pet: _selectedPet,
        petService: _petService,
      ),
    );
  }

  void _onAddMeasurement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLogBottomSheet(
        pet: _selectedPet,
        petService: _petService,
      ),
    );
  }

  void _onAddVaccination() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLogBottomSheet(
        pet: _selectedPet,
        petService: _petService,
      ),
    );
  }

  void _onViewHealthHistory() {
    // TODO: Implement health history view
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PetSelector(
              pets: widget.pets,
              selectedPet: _selectedPet,
              onPetSelected: _onPetSelected,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  FoodCard(
                    pet: _selectedPet,
                    onAddLog: _onAddFoodLog,
                  ),
                  const SizedBox(height: 16),
                  MeasurementsCard(
                    pet: _selectedPet,
                    onAddMeasurement: _onAddMeasurement,
                  ),
                  const SizedBox(height: 16),
                  HealthCard(
                    pet: _selectedPet,
                    onAddVaccination: _onAddVaccination,
                    onViewHistory: _onViewHealthHistory,
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