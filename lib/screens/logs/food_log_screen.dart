import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/logs/base_log_screen.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:intl/intl.dart';

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

class _FoodLogScreenState extends State<FoodLogScreen> {
  @override
  Stream getLogStream() {
    return widget.petService.getFoodLogs(widget.pet.id);
  }

  @override
  Widget buildLogItem(dynamic log) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.restaurant),
        title: Text(log.foodName),
        subtitle: Text(
          '${log.amount}g • ${log.energyPerGram * log.amount} kcal',
        ),
        trailing: Text(
          DateFormat('MMM d, h:mm a').format(log.timestamp),
        ),
      ),
    );
  }

  @override
  Future<void> _showAddEntryDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String foodName = '';
    double amount = 0;
    double energyPerGram = 0;

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
                  await widget.petService.addFoodLog(
                    widget.pet.id,
                    foodName,
                    amount,
                    energyPerGram,
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
} 