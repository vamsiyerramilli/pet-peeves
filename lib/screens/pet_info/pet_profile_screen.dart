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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updatedPet = widget.pet.copyWith(
        name: _nameController.text,
        species: _speciesController.text,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        adoptionDate: _adoptionDate,
        foods: _foods,
        measurements: _measurements,
      );

      await widget.petService.updatePet(updatedPet);
      setState(() => _isEditing = false);
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
                  ? TextFormField(
                      controller: _speciesController,
                      decoration: const InputDecoration(
                        labelText: 'Species',
                        border: OutlineInputBorder(),
                      ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Health Metrics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // TODO: Implement add measurements
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.pet.measurements != null) ...[
              _buildInfoRow(
                'Weight',
                Text('${widget.pet.measurements!.weight} kg'),
              ),
              _buildInfoRow(
                'Height',
                Text('${widget.pet.measurements!.height} cm'),
              ),
              _buildInfoRow(
                'Length',
                Text('${widget.pet.measurements!.length} cm'),
              ),
            ] else
              const Text('No measurements recorded'),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Food Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // TODO: Implement add food
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.pet.foods?.isNotEmpty ?? false)
              ...widget.pet.foods!.map((food) => _buildInfoRow(
                    food.name,
                    Text('${food.energyPerGram} kcal/g'),
                  ))
            else
              const Text('No food preferences recorded'),
          ],
        ),
      ),
    );
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
} 