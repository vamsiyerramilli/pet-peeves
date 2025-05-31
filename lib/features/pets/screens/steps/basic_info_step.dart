import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/pet_model.dart';
import '../../../core/theme/app_theme.dart';

class BasicInfoStep extends StatefulWidget {
  final Function(String) onNameChanged;
  final Function(Species?) onSpeciesChanged;
  final Function(String?) onOtherSpeciesChanged;
  final Function(Gender?) onGenderChanged;
  final Function(DateTime?) onDateOfBirthChanged;
  final Function(DateTime?) onAdoptionDateChanged;
  final Function(File?) onProfilePhotoChanged;

  final String initialName;
  final Species initialSpecies;
  final String? initialOtherSpecies;
  final Gender initialGender;
  final DateTime? initialDateOfBirth;
  final DateTime? initialAdoptionDate;
  final File? initialProfilePhoto;

  const BasicInfoStep({
    super.key,
    required this.onNameChanged,
    required this.onSpeciesChanged,
    required this.onOtherSpeciesChanged,
    required this.onGenderChanged,
    required this.onDateOfBirthChanged,
    required this.onAdoptionDateChanged,
    required this.onProfilePhotoChanged,
    this.initialName = '',
    this.initialSpecies = Species.dog,
    this.initialOtherSpecies,
    this.initialGender = Gender.male,
    this.initialDateOfBirth,
    this.initialAdoptionDate,
    this.initialProfilePhoto,
  });

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  final _nameController = TextEditingController();
  final _otherSpeciesController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _otherSpeciesController.text = widget.initialOtherSpecies ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _otherSpeciesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        widget.onProfilePhotoChanged(File(image.path));
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile photo
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.colors.background,
                backgroundImage: widget.initialProfilePhoto != null
                    ? FileImage(widget.initialProfilePhoto!)
                    : null,
                child: widget.initialProfilePhoto == null
                    ? const Icon(Icons.pets, size: 60)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Name field
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Pet Name',
            hintText: 'Enter your pet\'s name',
          ),
          onChanged: widget.onNameChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Species selection
        DropdownButtonFormField<Species>(
          value: widget.initialSpecies,
          decoration: const InputDecoration(
            labelText: 'Species',
            hintText: 'Select your pet\'s species',
          ),
          items: Species.values.map((species) {
            return DropdownMenuItem(
              value: species,
              child: Text(species.toString().split('.').last.toUpperCase()),
            );
          }).toList(),
          onChanged: widget.onSpeciesChanged,
        ),
        const SizedBox(height: 16),

        // Other species field (shown only when species is 'other')
        if (widget.initialSpecies == Species.other)
          TextFormField(
            controller: _otherSpeciesController,
            decoration: const InputDecoration(
              labelText: 'Other Species',
              hintText: 'Please specify',
            ),
            onChanged: widget.onOtherSpeciesChanged,
            validator: (value) {
              if (widget.initialSpecies == Species.other &&
                  (value == null || value.isEmpty)) {
                return 'Please specify the species';
              }
              return null;
            },
          ),
        const SizedBox(height: 16),

        // Gender selection
        DropdownButtonFormField<Gender>(
          value: widget.initialGender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            hintText: 'Select your pet\'s gender',
          ),
          items: Gender.values.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(gender.toString().split('.').last.toUpperCase()),
            );
          }).toList(),
          onChanged: widget.onGenderChanged,
        ),
        const SizedBox(height: 16),

        // Date of birth
        ListTile(
          title: const Text('Date of Birth'),
          subtitle: Text(
            widget.initialDateOfBirth != null
                ? '${widget.initialDateOfBirth!.day}/${widget.initialDateOfBirth!.month}/${widget.initialDateOfBirth!.year}'
                : 'Not set',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: widget.initialDateOfBirth ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              widget.onDateOfBirthChanged(date);
            }
          },
        ),
        const SizedBox(height: 8),

        // Adoption date
        ListTile(
          title: const Text('Adoption Date'),
          subtitle: Text(
            widget.initialAdoptionDate != null
                ? '${widget.initialAdoptionDate!.day}/${widget.initialAdoptionDate!.month}/${widget.initialAdoptionDate!.year}'
                : 'Not set',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: widget.initialAdoptionDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              widget.onAdoptionDateChanged(date);
            }
          },
        ),
      ],
    );
  }
} 