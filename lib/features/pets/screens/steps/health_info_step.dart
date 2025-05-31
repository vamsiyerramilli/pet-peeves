import 'package:flutter/material.dart';
import '../../models/health_log_model.dart';
import '../../../core/theme/app_theme.dart';

class HealthInfoStep extends StatefulWidget {
  final Function(VaccinationStatus?) onVaccinationStatusChanged;
  final Function(String?) onNotesChanged;

  final VaccinationStatus? initialVaccinationStatus;
  final String? initialNotes;

  const HealthInfoStep({
    super.key,
    required this.onVaccinationStatusChanged,
    required this.onNotesChanged,
    this.initialVaccinationStatus,
    this.initialNotes,
  });

  @override
  State<HealthInfoStep> createState() => _HealthInfoStepState();
}

class _HealthInfoStepState extends State<HealthInfoStep> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.initialNotes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Vaccination status
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vaccination Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VaccinationStatus>(
                  value: widget.initialVaccinationStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    hintText: 'Select vaccination status',
                  ),
                  items: VaccinationStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.toString().split('.').last
                            .replaceAll(RegExp(r'(?=[A-Z])'), ' ')
                            .trim()
                            .toUpperCase(),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.onVaccinationStatusChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Notes
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Additional Health Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Add any health-related notes or concerns',
                  ),
                  maxLines: 4,
                  onChanged: widget.onNotesChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Help text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.colors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Health Information Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('• Keep track of vaccination dates and status'),
              Text('• Note any allergies or medical conditions'),
              Text('• Record any medications or supplements'),
              Text('• All health information is optional'),
            ],
          ),
        ),
      ],
    );
  }
} 