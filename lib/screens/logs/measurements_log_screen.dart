import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/logs/base_log_screen.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:intl/intl.dart';

class MeasurementsLogScreen extends BaseLogScreen {
  final PetService petService;

  const MeasurementsLogScreen({
    super.key,
    required super.pet,
    required this.petService,
  }) : super(
          title: 'Measurements Log',
          emptyMessage: 'No measurements recorded yet',
        );

  @override
  State<MeasurementsLogScreen> createState() => _MeasurementsLogScreenState();
}

class _MeasurementsLogScreenState extends State<MeasurementsLogScreen> {
  @override
  Stream getLogStream() {
    return widget.petService.getMeasurementLogs(widget.pet.id);
  }

  @override
  Widget buildLogItem(dynamic log) {
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
                  DateFormat('MMM d, y').format(log.timestamp),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  DateFormat('h:mm a').format(log.timestamp),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMeasurementRow('Weight', '${log.weight} kg', Icons.monitor_weight),
            _buildMeasurementRow('Height', '${log.height} cm', Icons.height),
            _buildMeasurementRow('Length', '${log.length} cm', Icons.straighten),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> _showAddEntryDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    double weight = 0;
    double height = 0;
    double length = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Measurements'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Weight is required';
                  final weight = double.tryParse(value!);
                  if (weight == null || weight <= 0) {
                    return 'Enter a valid weight';
                  }
                  return null;
                },
                onSaved: (value) => weight = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Height is required';
                  final height = double.tryParse(value!);
                  if (height == null || height <= 0) {
                    return 'Enter a valid height';
                  }
                  return null;
                },
                onSaved: (value) => height = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Length (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Length is required';
                  final length = double.tryParse(value!);
                  if (length == null || length <= 0) {
                    return 'Enter a valid length';
                  }
                  return null;
                },
                onSaved: (value) => length = double.parse(value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                try {
                  await widget.petService.addMeasurementLog(
                    widget.pet.id,
                    weight,
                    height,
                    length,
                  );
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding measurements: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
} 