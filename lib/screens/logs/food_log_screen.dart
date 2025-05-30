import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/logs/base_log_screen.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:intl/intl.dart';
import 'package:pet_peeves/models/logs.dart';

class FoodLogScreen extends BaseLogScreen {
  final PetService petService;

  const FoodLogScreen({
    super.key,
    required super.pet,
    required this.petService,
  }) : super(
          title: 'Food Log',
          emptyMessage: 'No food entries yet',
        );

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends BaseLogScreenState<FoodLogScreen> {
  @override
  Stream getLogStream() {
    return widget.petService.getFoodLogs(widget.pet.id);
  }

  @override
  Widget buildLogItem(dynamic log) {
    final foodLog = log as FoodLog;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => _showEditEntryDialog(context, foodLog),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    foodLog.foodName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    DateFormat('MMM d, h:mm a').format(foodLog.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Text(
                '${foodLog.amount}g • ${foodLog.energyContent! * foodLog.amount} kcal',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> showAddEntryDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String foodName = '';
    double amount = 0;
    double energyPerGram = 0;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Food Entry'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Food name is required' : null,
                onSaved: (value) => foodName = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Amount is required';
                  final amount = double.tryParse(value!);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => amount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Energy (kcal/g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Energy is required';
                  final energy = double.tryParse(value!);
                  if (energy == null || energy <= 0) {
                    return 'Enter a valid energy value';
                  }
                  return null;
                },
                onSaved: (value) => energyPerGram = double.parse(value!),
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
                try {
                  if (widget.pet.id == null) {
                    throw Exception('Pet ID is required to add a food log');
                  }
                  await widget.petService.addFoodLog(
                    petId: widget.pet.id!,
                    foodName: foodName,
                    amount: amount,
                    energyPerGram: energyPerGram,
                    timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
                  );
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding food log: $e')),
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

  Future<void> _showEditEntryDialog(BuildContext context, FoodLog foodLog) async {
    final formKey = GlobalKey<FormState>();
    String foodName = foodLog.foodName;
    double amount = foodLog.amount;
    double energyPerGram = foodLog.energyContent!;
    DateTime selectedDate = foodLog.timestamp;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(foodLog.timestamp);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Food Entry'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: foodName,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Food name is required' : null,
                onSaved: (value) => foodName = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: amount.toString(),
                decoration: const InputDecoration(
                  labelText: 'Amount (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Amount is required';
                  final amount = double.tryParse(value!);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => amount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: energyPerGram.toString(),
                decoration: const InputDecoration(
                  labelText: 'Energy (kcal/g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Energy is required';
                  final energy = double.tryParse(value!);
                  if (energy == null || energy <= 0) {
                    return 'Enter a valid energy value';
                  }
                  return null;
                },
                onSaved: (value) => energyPerGram = double.parse(value!),
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
                if (foodLog.id == null) {
                  throw Exception('Food log ID is required to delete');
                }
                await widget.petService.deleteFoodLog(foodLog.petId, foodLog.id!);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting food log: $e')),
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
                  if (foodLog.id == null) {
                    throw Exception('Food log ID is required to update');
                  }
                  final updatedFoodLog = FoodLog(
                    id: foodLog.id,
                    petId: foodLog.petId,
                    timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
                    notes: foodLog.notes,
                    foodName: foodName,
                    amount: amount,
                    unit: foodLog.unit,
                    energyContent: energyPerGram,
                  );
                  await widget.petService.updateFoodLog(updatedFoodLog);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating food log: $e')),
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