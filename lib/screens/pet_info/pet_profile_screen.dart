import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:intl/intl.dart';

class PetProfileScreen extends StatefulWidget {
  final Pet pet;
  final PetService petService;

  const PetProfileScreen({
    super.key,
    required this.pet,
    required this.petService,
  });

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late DateTime? _dateOfBirth;
  late String _gender;
  late DateTime? _adoptionDate;
  late List<PetFood> _foods;
  late PetMeasurements? _measurements;

  // Add controllers for measurements
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _lengthController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    // Initialize measurement controllers here
    _weightController = TextEditingController(text: _measurements?.weight?.toString() ?? '');
    _heightController = TextEditingController(text: _measurements?.height?.toString() ?? '');
    _lengthController = TextEditingController(text: _measurements?.length?.toString() ?? '');
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.pet.name);
    _speciesController = TextEditingController(text: widget.pet.species);
    _dateOfBirth = widget.pet.dateOfBirth;
    _gender = widget.pet.gender;
    _adoptionDate = widget.pet.adoptionDate;
    _foods = widget.pet.foods ?? [];
    _measurements = widget.pet.measurements;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    // Dispose measurement controllers
    _weightController.dispose();
    _heightController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    // Parse measurement values from controllers
    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);
    final double? length = double.tryParse(_lengthController.text);

    // Create updated measurements object
    final PetMeasurements? updatedMeasurements = (weight != null && height != null && length != null)
        ? PetMeasurements(weight: weight, height: height, length: length)
        : null; // Set to null if any field is empty or invalid

    try {
      final updatedPet = widget.pet.copyWith(
        name: _nameController.text,
        species: _speciesController.text,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        adoptionDate: _adoptionDate,
        foods: _foods, // Keep existing foods for now
        measurements: updatedMeasurements, // Use the updated measurements
      );

      await widget.petService.updatePet(updatedPet);
      setState(() {
        _isEditing = false;
        _measurements = updatedMeasurements; // Update local state after saving
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
          if (!_isEditing) // Show these options only when not editing
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'archive') {
                  _archivePet();
                } else if (value == 'delete') {
                  _deletePet();
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'archive',
                    child: Text('Archive Pet'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete Pet'),
                  ),
                ];
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildHealthMetrics(),
              const SizedBox(height: 24),
              _buildFoodDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: widget.pet.photoURL != null
                ? NetworkImage(widget.pet.photoURL!)
                : null,
            child: widget.pet.photoURL == null
                ? Text(
                    widget.pet.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          if (_isEditing)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Name is required' : null,
            )
          else
            Text(
              widget.pet.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Species',
              _isEditing
                  ? DropdownButtonFormField<String>(
                      value: _speciesController.text,
                      decoration: const InputDecoration(
                        labelText: 'Species',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Dog', 'Cat', 'Bird', 'Other'] // Assuming these are the species options
                          .map((species) => DropdownMenuItem(
                                value: species,
                                child: Text(species),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _speciesController.text = value; // Update controller text
                        }
                      },
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Species is required' : null,
                    )
                  : Text(widget.pet.species),
            ),
            _buildInfoRow(
              'Gender',
              _isEditing
                  ? DropdownButtonFormField<String>(
                      value: _gender,
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                      ],
                      onChanged: (value) =>
                          setState(() => _gender = value ?? _gender),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    )
                  : Text(widget.pet.gender),
            ),
            _buildInfoRow(
              'Date of Birth',
              _isEditing
                  ? TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateOfBirth ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _dateOfBirth = date);
                        }
                      },
                      child: Text(
                        _dateOfBirth != null
                            ? DateFormat('MMM d, y').format(_dateOfBirth!)
                            : 'Not set',
                      ),
                      // Ensure TextButton is enabled
                      style: TextButton.styleFrom(
                        foregroundColor: _isEditing ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  : Text(
                      widget.pet.dateOfBirth != null
                          ? DateFormat('MMM d, y').format(widget.pet.dateOfBirth!)
                          : 'Not set',
                    ),
            ),
            if (widget.pet.adoptionDate != null)
              _buildInfoRow(
                'Adoption Date',
                _isEditing
                    ? TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _adoptionDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _adoptionDate = date);
                          }
                        },
                        child: Text(
                          _adoptionDate != null
                              ? DateFormat('MMM d, y').format(_adoptionDate!)
                              : 'Not set',
                        ),
                      )
                    : Text(
                        DateFormat('MMM d, y')
                            .format(widget.pet.adoptionDate!),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Measurements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Weight
            _buildInfoRow(
              'Weight (kg)',
              _isEditing
                  ? TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (double.tryParse(value) == null) return 'Enter a valid number';
                        if (double.parse(value) < 0) return 'Enter a positive number';
                        return null;
                      },
                    )
                  : Text(_measurements?.weight?.toString() ?? 'Not set'),
            ),
            // Height
            _buildInfoRow(
              'Height (cm)',
              _isEditing
                  ? TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Height'),
                       validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (double.tryParse(value) == null) return 'Enter a valid number';
                        if (double.parse(value) < 0) return 'Enter a positive number';
                        return null;
                      },
                    )
                  : Text(_measurements?.height?.toString() ?? 'Not set'),
            ),
            // Length
            _buildInfoRow(
              'Length (cm)',
              _isEditing
                  ? TextFormField(
                      controller: _lengthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Length'),
                       validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (double.tryParse(value) == null) return 'Enter a valid number';
                        if (double.parse(value) < 0) return 'Enter a positive number';
                        return null;
                      },
                    )
                  : Text(_measurements?.length?.toString() ?? 'Not set'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodDetails() {
    return const SizedBox.shrink(); // Hide this section for now
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  Future<void> _archivePet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Pet'),
        content: Text('Are you sure you want to archive ${widget.pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Don't archive
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Archive
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Update the pet's status to archived
        final archivedPet = widget.pet.copyWith(isArchived: true);
        await widget.petService.updatePet(archivedPet);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.pet.name} archived')),
          );
          // Navigate back after archiving
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error archiving pet: $e')),
          );
        }
      }
    }
  }

  Future<void> _deletePet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to permanently delete ${widget.pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Don't delete
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Delete
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.petService.deletePet(widget.pet.id!); // Assuming id is not null for existing pets
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.pet.name} deleted')),
          );
          // Navigate back after deletion
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting pet: $e')),
          );
        }
      }
    }
  }
} 