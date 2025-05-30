import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:pet_peeves/widgets/onboarding/pet_form.dart';

class OnboardingScreen extends StatefulWidget {
  final String userId;
  final PetService petService;

  const OnboardingScreen({
    super.key,
    required this.userId,
    required this.petService,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<Pet> _pets = [];
  bool _isLoading = false;

  Future<void> _savePet(Pet pet) async {
    setState(() => _isLoading = true);
    try {
      await widget.petService.addPet(pet);
      setState(() {
        _pets.add(pet);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving pet: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _completeOnboarding() async {
    if (_pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one pet')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.petService.updateUserHasPets(widget.userId, true);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing onboarding: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Pets'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _completeOnboarding,
            child: const Text('Done'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_pets.isNotEmpty)
                  Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pets.length,
                      itemBuilder: (context, index) {
                        final pet = _pets[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundImage: pet.photoURL != null
                                      ? NetworkImage(pet.photoURL!)
                                      : null,
                                  child: pet.photoURL == null
                                      ? Text(pet.name[0].toUpperCase())
                                      : null,
                                ),
                                const SizedBox(height: 4),
                                Text(pet.name),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: PetForm(
                      onSave: _savePet,
                      onSkip: _completeOnboarding,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 