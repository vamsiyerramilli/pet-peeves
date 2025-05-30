import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';

class PetSelector extends StatelessWidget {
  final List<Pet> pets;
  final Pet? selectedPet;
  final Function(Pet) onPetSelected;

  const PetSelector({
    super.key,
    required this.pets,
    required this.selectedPet,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                final isSelected = pet.id == selectedPet?.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _PetPill(
                    pet: pet,
                    isSelected: isSelected,
                    onTap: () => onPetSelected(pet),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _PetPill extends StatelessWidget {
  final Pet pet;
  final bool isSelected;
  final VoidCallback onTap;

  const _PetPill({
    required this.pet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected ? colorScheme.primary : colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: pet.photoURL != null
                    ? NetworkImage(pet.photoURL!)
                    : null,
                child: pet.photoURL == null
                    ? Text(
                        pet.name[0].toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                          fontSize: 12,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                pet.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 