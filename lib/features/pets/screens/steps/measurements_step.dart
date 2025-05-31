import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class MeasurementsStep extends StatefulWidget {
  final Function(double?) onWeightChanged;
  final Function(double?) onLengthChanged;
  final Function(double?) onHeightChanged;
  final Function(String?) onNotesChanged;

  final double? initialWeight;
  final double? initialLength;
  final double? initialHeight;
  final String? initialNotes;

  const MeasurementsStep({
    super.key,
    required this.onWeightChanged,
    required this.onLengthChanged,
    required this.onHeightChanged,
    required this.onNotesChanged,
    this.initialWeight,
    this.initialLength,
    this.initialHeight,
    this.initialNotes,
  });

  @override
  State<MeasurementsStep> createState() => _MeasurementsStepState();
}

class _MeasurementsStepState extends State<MeasurementsStep> {
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weightController.text = widget.initialWeight?.toString() ?? '';
    _lengthController.text = widget.initialLength?.toString() ?? '';
    _heightController.text = widget.initialHeight?.toString() ?? '';
    _notesController.text = widget.initialNotes ?? '';
  }

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Weight input
        TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Weight',
            hintText: 'Enter weight in kg',
            suffixText: 'kg',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: (value) {
            widget.onWeightChanged(
              value.isEmpty ? null : double.tryParse(value),
            );
          },
        ),
        const SizedBox(height: 16),

        // Length input
        TextFormField(
          controller: _lengthController,
          decoration: const InputDecoration(
            labelText: 'Length',
            hintText: 'Enter length in cm',
            suffixText: 'cm',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: (value) {
            widget.onLengthChanged(
              value.isEmpty ? null : double.tryParse(value),
            );
          },
        ),
        const SizedBox(height: 16),

        // Height input
        TextFormField(
          controller: _heightController,
          decoration: const InputDecoration(
            labelText: 'Height',
            hintText: 'Enter height in cm',
            suffixText: 'cm',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: (value) {
            widget.onHeightChanged(
              value.isEmpty ? null : double.tryParse(value),
            );
          },
        ),
        const SizedBox(height: 16),

        // Notes
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Add any additional notes about the measurements',
          ),
          maxLines: 3,
          onChanged: widget.onNotesChanged,
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
                'Measurement Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('• Weight: Measure when your pet is calm and still'),
              Text('• Length: Measure from nose to tail base'),
              Text('• Height: Measure from ground to shoulder'),
              Text('• All measurements are optional'),
            ],
          ),
        ),
      ],
    );
  }
} 