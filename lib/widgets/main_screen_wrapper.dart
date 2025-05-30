import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:pet_peeves/widgets/logs/add_log_bottom_sheet.dart';

class MainScreenWrapper extends StatelessWidget {
  final Widget child;
  final Pet pet;
  final PetService petService;
  final bool showFab;

  const MainScreenWrapper({
    super.key,
    required this.child,
    required this.pet,
    required this.petService,
    this.showFab = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              heroTag: 'add_log_fab',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddLogBottomSheet(
                    pet: pet,
                    petService: petService,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Log'),
              elevation: 4,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
} 