import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/widgets/dashboard/dashboard_cards.dart';
import 'package:pet_peeves/widgets/pet_selector.dart';

class DashboardScreen extends StatefulWidget {
  final List<Pet> pets;

  const DashboardScreen({
    super.key,
    required this.pets,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Pet _selectedPet;

  @override
  void initState() {
    super.initState();
    _selectedPet = widget.pets.first;
  }

  void _onPetSelected(Pet pet) {
    setState(() {
      _selectedPet = pet;
    });
  }

  void _onAddFoodLog() {
    // TODO: Implement food log addition
  }

  void _onAddMeasurement() {
    // TODO: Implement measurement addition
  }

  void _onAddVaccination() {
    // TODO: Implement vaccination addition
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