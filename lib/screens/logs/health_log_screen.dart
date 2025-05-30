import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/logs/base_log_screen.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:intl/intl.dart';

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

class _HealthLogScreenState extends State<HealthLogScreen> {
  @override
  Stream getLogStream() {
    return widget.petService.getHealthLogs(widget.pet.id);
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
                  log.type,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  DateFormat('MMM d, y').format(log.timestamp),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (log.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                log.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (log.nextDueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Next due: ${DateFormat('MMM d, y').format(log.nextDueDate!)}',
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
    );
  }

  @override
  Future<void> _showAddEntryDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String type = 'Vaccination';
    String notes = '';
    DateTime? nextDueDate;

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
                title: const Text('Next Due Date'),
                subtitle: Text(
                  nextDueDate != null
                      ? DateFormat('MMM d, y').format(nextDueDate)
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
                  await widget.petService.addHealthLog(
                    widget.pet.id,
                    type,
                    notes,
                    nextDueDate,
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
} 