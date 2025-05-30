import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/logs/base_log_screen.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:intl/intl.dart';
import 'package:pet_peeves/models/logs.dart';

class HealthLogScreen extends BaseLogScreen {
  final PetService petService;

  const HealthLogScreen({
    super.key,
    required super.pet,
    required this.petService,
  }) : super(
          title: 'Health Log',
          emptyMessage: 'No health records yet',
        );

  @override
  State<HealthLogScreen> createState() => _HealthLogScreenState();
}

class _HealthLogScreenState extends BaseLogScreenState<HealthLogScreen> {
  @override
  Stream getLogStream() {
    return widget.petService.getHealthLogs(widget.pet.id);
  }

  @override
  Widget buildLogItem(dynamic log) {
    final healthLog = log as HealthLog;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => _showEditEntryDialog(context, healthLog),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    healthLog.condition,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    DateFormat('MMM d, y').format(healthLog.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (healthLog.notes.isNotEmpty) ...[
                const SizedBox(height: 4.0),
                Text(
                  healthLog.notes,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (healthLog.nextDueDate != null) ...[
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Next due: ${DateFormat('MMM d, y').format(healthLog.nextDueDate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> showAddEntryDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String type = 'Vaccination';
    String notes = '';
    DateTime? nextDueDate;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Record'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'Vaccination', child: Text('Vaccination')),
                  DropdownMenuItem(value: 'Checkup', child: Text('Checkup')),
                  DropdownMenuItem(value: 'Medication', child: Text('Medication')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => type = value ?? type),
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => notes = value ?? '',
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
              ListTile(
                title: const Text('Next Due Date'),
                subtitle: Text(
                  nextDueDate != null
                      ? DateFormat('MMM d, y').format(nextDueDate!)
                      : 'Not set',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (date != null) {
                      setState(() => nextDueDate = date);
                    }
                  },
                ),
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
                  if (widget.pet.id == null) {
                    throw Exception('Pet ID is required to add a health record');
                  }
                  await widget.petService.addHealthLog(
                    petId: widget.pet.id!,
                    type: type,
                    notes: notes,
                    nextDueDate: nextDueDate,
                    timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
                  );
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding health record: $e')),
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

  Future<void> _showEditEntryDialog(BuildContext context, HealthLog healthLog) async {
    final formKey = GlobalKey<FormState>();
    String type = healthLog.condition;
    String notes = healthLog.notes;
    DateTime? nextDueDate = healthLog.nextDueDate;
    DateTime selectedDate = healthLog.timestamp;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(healthLog.timestamp);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Health Record'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'Vaccination', child: Text('Vaccination')),
                  DropdownMenuItem(value: 'Checkup', child: Text('Checkup')),
                  DropdownMenuItem(value: 'Medication', child: Text('Medication')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => type = value ?? type),
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => notes = value ?? '',
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
              ListTile(
                title: const Text('Next Due Date'),
                subtitle: Text(
                  nextDueDate != null
                      ? DateFormat('MMM d, y').format(nextDueDate!)
                      : 'Not set',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: nextDueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (date != null) {
                      setState(() => nextDueDate = date);
                    }
                  },
                ),
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
                if (healthLog.id == null) {
                  throw Exception('Health log ID is required to delete');
                }
                await widget.petService.deleteHealthLog(healthLog.petId, healthLog.id!);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting health log: $e')),
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
                try {
                  if (healthLog.id == null) {
                    throw Exception('Health log ID is required to update');
                  }
                  final updatedHealthLog = HealthLog(
                    id: healthLog.id,
                    petId: healthLog.petId,
                    timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
                    notes: notes,
                    condition: type,
                    severity: healthLog.severity,
                    symptoms: healthLog.symptoms,
                    diagnosis: healthLog.diagnosis,
                    treatment: healthLog.treatment,
                    nextDueDate: nextDueDate,
                  );
                  await widget.petService.updateHealthLog(updatedHealthLog);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating health log: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
} 