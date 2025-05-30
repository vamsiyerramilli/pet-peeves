import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:pet_peeves/widgets/onboarding/pet_form.dart';
import 'package:pet_peeves/routes/app_router.dart';

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
  final _formKey = GlobalKey<PetFormState>();

  Future<void> _savePet(Pet pet) async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      await widget.petService.addPet(pet);
      if (!mounted) return;
      
      setState(() {
        _pets.add(pet);
        _isLoading = false;  // Reset loading state after successful save
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet saved successfully!')),
      );
      _formKey.currentState?.resetForm();
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);  // Reset loading state on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving pet: $e')),
      );
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
        Navigator.pushReplacementNamed(
          context,
          AppRouter.dashboard,
          arguments: {'pets': _pets},
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing onboarding: $e')),
        );
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
      body: Column(
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: PetForm(
                    key: _formKey,
                    onSave: _savePet,
                    onSkip: _completeOnboarding,
                  ),
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 