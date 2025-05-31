import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/pet_model.dart';
import '../../models/health_log_model.dart';
import '../../../core/theme/app_theme.dart';

class ReviewStep extends StatelessWidget {
  final String name;
  final Species species;
  final String? otherSpecies;
  final Gender gender;
  final DateTime? dateOfBirth;
  final DateTime? adoptionDate;
  final File? profilePhoto;

  final double? weight;
  final double? length;
  final double? height;
  final String? measurementNotes;

  final VaccinationStatus? vaccinationStatus;
  final String? healthNotes;

  const ReviewStep({
    super.key,
    required this.name,
    required this.species,
    this.otherSpecies,
    required this.gender,
    this.dateOfBirth,
    this.adoptionDate,
    this.profilePhoto,
    this.weight,
    this.length,
    this.height,
    this.measurementNotes,
    this.vaccinationStatus,
    this.healthNotes,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile photo
          if (profilePhoto != null)
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: FileImage(profilePhoto!),
              ),
            ),
          const SizedBox(height: 24),

          // Basic Information
          _buildSection(
            title: 'Basic Information',
            children: [
              _buildInfoRow('Name', name),
              _buildInfoRow(
                'Species',
                species == Species.other
                    ? otherSpecies ?? 'Other'
                    : species.toString().split('.').last.toUpperCase(),
              ),
              _buildInfoRow(
                'Gender',
                gender.toString().split('.').last.toUpperCase(),
              ),
              if (dateOfBirth != null)
                _buildInfoRow(
                  'Date of Birth',
                  '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}',
                ),
              if (adoptionDate != null)
                _buildInfoRow(
                  'Adoption Date',
                  '${adoptionDate!.day}/${adoptionDate!.month}/${adoptionDate!.year}',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Measurements
          if (weight != null || length != null || height != null)
            _buildSection(
              title: 'Measurements',
              children: [
                if (weight != null)
                  _buildInfoRow('Weight', '${weight!.toStringAsFixed(1)} kg'),
                if (length != null)
                  _buildInfoRow('Length', '${length!.toStringAsFixed(1)} cm'),
                if (height != null)
                  _buildInfoRow('Height', '${height!.toStringAsFixed(1)} cm'),
                if (measurementNotes != null && measurementNotes!.isNotEmpty)
                  _buildInfoRow('Notes', measurementNotes!),
              ],
            ),
          const SizedBox(height: 16),

          // Health Information
          if (vaccinationStatus != null || healthNotes != null)
            _buildSection(
              title: 'Health Information',
              children: [
                if (vaccinationStatus != null)
                  _buildInfoRow(
                    'Vaccination Status',
                    vaccinationStatus.toString().split('.').last
                        .replaceAll(RegExp(r'(?=[A-Z])'), ' ')
                        .trim()
                        .toUpperCase(),
                  ),
                if (healthNotes != null && healthNotes!.isNotEmpty)
                  _buildInfoRow('Notes', healthNotes!),
              ],
            ),
          const SizedBox(height: 24),

          // Confirmation message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.colors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to Create Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please review all the information above. You can go back to make changes if needed.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 