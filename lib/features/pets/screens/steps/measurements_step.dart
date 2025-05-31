import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class MeasurementsStep extends StatefulWidget {
  final Function(double?) onWeightChanged;
  final Function(double?) onLengthChanged;
  final Function(double?) onHeightChanged;
  final VoidCallback onSkip;

  final double? initialWeight;
  final double? initialLength;
  final double? initialHeight;

  const MeasurementsStep({
    super.key,
    required this.onWeightChanged,
    required this.onLengthChanged,
    required this.onHeightChanged,
    required this.onSkip,
    this.initialWeight,
    this.initialLength,
    this.initialHeight,
  });

  @override
  State<MeasurementsStep> createState() => _MeasurementsStepState();
}

class _MeasurementsStepState extends State<MeasurementsStep> {
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weightController.text = widget.initialWeight?.toString() ?? '';
    _lengthController.text = widget.initialLength?.toString() ?? '';
    _heightController.text = widget.initialHeight?.toString() ?? '';
  }

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
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
            labelText: 'Weight (in kg)',
            hintText: 'Enter weight',
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
            labelText: 'Length (in cm)',
            hintText: 'Enter length',
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
            labelText: 'Height (in cm)',
            hintText: 'Enter height',
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
        const SizedBox(height: 24),

        // Skip button
        TextButton(
          onPressed: widget.onSkip,
          child: const Text('Skip Measurements'),
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