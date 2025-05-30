import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/logs/base_log_screen.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:intl/intl.dart';
import 'package:pet_peeves/models/logs.dart';

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

class _MeasurementsLogScreenState extends BaseLogScreenState<MeasurementsLogScreen> {
  @override
  Stream getLogStream() {
    return widget.petService.getMeasurementLogs(widget.pet.id);
  }

  @override
  Widget buildLogItem(dynamic log) {
    final measurementLog = log as MeasurementLog;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => _showEditEntryDialog(context, measurementLog),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, y').format(measurementLog.timestamp),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    DateFormat('h:mm a').format(measurementLog.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (measurementLog.weight > 0) _buildMeasurementRow('Weight', '${measurementLog.weight} kg', Icons.monitor_weight),
              if (measurementLog.height > 0) _buildMeasurementRow('Height', '${measurementLog.height} cm', Icons.height),
              if (measurementLog.length > 0) _buildMeasurementRow('Length', '${measurementLog.length} cm', Icons.straighten),
            ],
          ),
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
  Future<void> showAddEntryDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    double weight = 0;
    double height = 0;
    double length = 0;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

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
                validator: (value) => null,
                onSaved: (value) => weight = double.tryParse(value ?? '') ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => null,
                onSaved: (value) => height = double.tryParse(value ?? '') ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Length (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => null,
                onSaved: (value) => length = double.tryParse(value ?? '') ?? 0,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('Time'),
                subtitle: Text(selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
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
                if (weight <= 0 && height <= 0 && length <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter at least one measurement (weight, height, or length).')),
                  );
                  return;
                }
                try {
                  if (widget.pet.id == null) {
                    throw Exception('Pet ID is required to add measurements');
                  }
                  await widget.petService.addMeasurementLog(
                    petId: widget.pet.id!,
                    weight: weight,
                    height: height,
                    length: length,
                    timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
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

  Future<void> _showEditEntryDialog(BuildContext context, MeasurementLog measurementLog) async {
    final formKey = GlobalKey<FormState>();
    double weight = measurementLog.weight;
    double height = measurementLog.height;
    double length = measurementLog.length;
    DateTime selectedDate = measurementLog.timestamp;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(measurementLog.timestamp);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Measurements'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: weight > 0 ? weight.toString() : '',
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => null,
                onSaved: (value) => weight = double.tryParse(value ?? '') ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: height > 0 ? height.toString() : '',
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => null,
                onSaved: (value) => height = double.tryParse(value ?? '') ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: length > 0 ? length.toString() : '',
                decoration: const InputDecoration(
                  labelText: 'Length (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => null,
                onSaved: (value) => length = double.tryParse(value ?? '') ?? 0,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('Time'),
                subtitle: Text(selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (measurementLog.id == null) {
                  throw Exception('Measurement log ID is required to delete');
                }
                await widget.petService.deleteMeasurementLog(measurementLog.petId, measurementLog.id!);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting measurement log: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                if (weight <= 0 && height <= 0 && length <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter at least one measurement (weight, height, or length).')),
                  );
                  return;
                }
                try {
                  if (measurementLog.id == null) {
                    throw Exception('Measurement log ID is required to update');
                  }
                  final updatedMeasurementLog = MeasurementLog(
                    id: measurementLog.id,
                    petId: measurementLog.petId,
                    timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
                    notes: measurementLog.notes,
                    weight: weight,
                    height: height,
                    length: length,
                  );
                  await widget.petService.updateMeasurementLog(updatedMeasurementLog);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating measurement log: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 