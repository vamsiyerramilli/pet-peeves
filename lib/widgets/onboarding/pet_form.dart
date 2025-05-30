import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/providers/auth_provider.dart';

class PetForm extends StatefulWidget {
  final Function(Pet) onSave;
  final VoidCallback onSkip;

  const PetForm({
    super.key,
    required this.onSave,
    required this.onSkip,
  });

  @override
  State<PetForm> createState() => PetFormState();
}

class PetFormState extends State<PetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedSpecies = 'Dog';
  DateTime? _dateOfBirth;
  String _selectedGender = 'Male';
  bool _showOptionalFields = false;

  // Optional fields
  DateTime? _adoptionDate;
  String? _photoURL;
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _lengthController = TextEditingController();
  final List<PetFood> _foods = [];
  final List<PetVaccination> _vaccinations = [];

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Validate date of birth separately since it's not a TextFormField
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date of birth')),
      );
      return;
    }

    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      PetMeasurements? measurements;
      if (_showOptionalFields && _weightController.text.isNotEmpty && _heightController.text.isNotEmpty && _lengthController.text.isNotEmpty) {
        final weight = double.tryParse(_weightController.text);
        final height = double.tryParse(_heightController.text);
        final length = double.tryParse(_lengthController.text);
        if (weight != null && height != null && length != null) {
          measurements = PetMeasurements(
            weight: weight,
            height: height,
            length: length,
          );
        }
      }

      final pet = Pet(
        name: _nameController.text,
        species: _selectedSpecies,
        dateOfBirth: _dateOfBirth,
        gender: _selectedGender,
        adoptionDate: _adoptionDate,
        photoURL: _photoURL,
        measurements: measurements,
        foods: _showOptionalFields ? _foods : null,
        vaccinations: _showOptionalFields ? _vaccinations : null,
        ownerId: userId,
      );

      widget.onSave(pet);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating pet: $e')),
      );
    }
  }

  void resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _weightController.clear();
    _heightController.clear();
    _lengthController.clear();
    setState(() {
      _selectedSpecies = 'Dog';
      _dateOfBirth = null;
      _selectedGender = 'Male';
      _adoptionDate = null;
      _photoURL = null;
      _foods.clear();
      _vaccinations.clear();
      _showOptionalFields = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Pet Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Species',
                border: OutlineInputBorder(),
              ),
              items: ['Dog', 'Cat', 'Bird', 'Other']
                  .map((species) => DropdownMenuItem(
                        value: species,
                        child: Text(species),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSpecies = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date of Birth'),
              subtitle: Text(_dateOfBirth == null
                  ? 'Not set'
                  : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _dateOfBirth = date);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: ['Male', 'Female']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedGender = value);
                }
              },
            ),
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text('Additional Information'),
              initiallyExpanded: false,
              onExpansionChanged: (expanded) {
                setState(() => _showOptionalFields = expanded);
              },
              children: [
                if (_showOptionalFields) ...[
                  ListTile(
                    title: const Text('Adoption Date'),
                    subtitle: Text(_adoptionDate == null
                        ? 'Not set'
                        : '${_adoptionDate!.day}/${_adoptionDate!.month}/${_adoptionDate!.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _adoptionDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final parsed = double.tryParse(value);
                      if (parsed == null) return 'Enter a valid number';
                      if (parsed < 0) return 'Enter a positive number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final parsed = double.tryParse(value);
                      if (parsed == null) return 'Enter a valid number';
                      if (parsed < 0) return 'Enter a positive number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lengthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Length (cm)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final parsed = double.tryParse(value);
                      if (parsed == null) return 'Enter a valid number';
                      if (parsed < 0) return 'Enter a positive number';
                      return null;
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Pet'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onSkip,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Skip for Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 