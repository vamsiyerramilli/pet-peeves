import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:uuid/uuid.dart';
import '../../../core/store/app_state.dart';
import '../models/food.dart';
import '../models/food_tracking_entry.dart';
import '../store/food_tracking_actions.dart';
import '../store/food_actions.dart';

class FoodEntryModal extends StatefulWidget {
  final String petId;
  final FoodTrackingEntry? entry;

  const FoodEntryModal({
    Key? key,
    required this.petId,
    this.entry,
  }) : super(key: key);

  @override
  State<FoodEntryModal> createState() => _FoodEntryModalState();
}

class _FoodEntryModalState extends State<FoodEntryModal> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedTime;
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  late TextEditingController _newFoodNameController;
  late TextEditingController _newFoodKcalController;
  Food? _selectedFood;
  FoodType _newFoodType = FoodType.dry;
  bool _isAddingNewFood = false;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.entry?.timestamp ?? DateTime.now();
    _weightController = TextEditingController(
      text: widget.entry?.weightGrams.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.entry?.notes ?? '',
    );
    _newFoodNameController = TextEditingController();
    _newFoodKcalController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    _newFoodNameController.dispose();
    _newFoodKcalController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Widget _buildNewFoodForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: _newFoodNameController,
          decoration: const InputDecoration(
            labelText: 'Food Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_isAddingNewFood && (value == null || value.isEmpty)) {
              return 'Please enter a food name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<FoodType>(
          value: _newFoodType,
          decoration: const InputDecoration(
            labelText: 'Food Type',
            border: OutlineInputBorder(),
          ),
          items: FoodType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.toString().split('.').last),
            );
          }).toList(),
          onChanged: (type) {
            if (type != null) {
              setState(() {
                _newFoodType = type;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newFoodKcalController,
          decoration: const InputDecoration(
            labelText: 'Calories per gram (optional)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final kcal = double.tryParse(value);
              if (kcal == null || kcal < 0) {
                return 'Please enter a valid number';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  void _saveEntry(_ViewModel vm) async {
    if (_formKey.currentState!.validate()) {
      final weight = double.parse(_weightController.text);
      
      Food food;
      if (_isAddingNewFood) {
        // Check for duplicate food names
        if (vm.foods.any((f) => f.name.toLowerCase() == _newFoodNameController.text.toLowerCase())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A food with this name already exists'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        food = Food(
          id: const Uuid().v4(),
          name: _newFoodNameController.text,
          type: _newFoodType,
          kCalPerGram: _newFoodKcalController.text.isNotEmpty
              ? double.parse(_newFoodKcalController.text)
              : null,
          createdAt: DateTime.now(),
        );
        vm.onAddFood(food);

        // Wait for the food to be added before proceeding
        if (vm.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding food: ${vm.error}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } else {
        food = _selectedFood!;
      }

      final kCal = food.kCalPerGram != null ? food.kCalPerGram! * weight : null;

      final entry = FoodTrackingEntry(
        id: widget.entry?.id ?? const Uuid().v4(),
        petId: widget.petId,
        timestamp: _selectedTime,
        foodId: food.id,
        foodName: food.name,
        type: food.type,
        kCalPerGram: food.kCalPerGram,
        weightGrams: weight,
        kCal: kCal,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: widget.entry?.createdAt ?? DateTime.now(),
        updatedAt: widget.entry != null ? DateTime.now() : null,
      );

      if (widget.entry == null) {
        vm.onAdd(entry);
      } else {
        vm.onUpdate(entry);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store, widget.petId),
      onWillChange: (_ViewModel? prev, _ViewModel next) {
        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: next.clearError,
                textColor: Colors.white,
              ),
            ),
          );
        }
      },
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.entry == null ? 'Add Food Entry' : 'Edit Food Entry'),
            actions: [
              if (vm.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () => _saveEntry(vm),
                  child: const Text('Save'),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Food Selection
                DropdownButtonFormField<Food>(
                  value: _selectedFood,
                  decoration: const InputDecoration(
                    labelText: 'Food',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    ...vm.foods.map((food) => DropdownMenuItem(
                          value: food,
                          child: Text(food.name),
                        )),
                    const DropdownMenuItem(
                      value: null,
                      child: Text('+ Add New Food'),
                    ),
                  ],
                  onChanged: (food) {
                    setState(() {
                      _selectedFood = food;
                      _isAddingNewFood = food == null;
                    });
                  },
                  validator: (value) {
                    if (value == null && !_isAddingNewFood) {
                      return 'Please select a food';
                    }
                    return null;
                  },
                ),
                if (_isAddingNewFood) _buildNewFoodForm(),
                const SizedBox(height: 16),

                // Weight Input
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (grams)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Please enter a valid weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date and Time Selection
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          '${_selectedTime.year}-${_selectedTime.month.toString().padLeft(2, '0')}-${_selectedTime.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectTime(context),
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes Input
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final List<Food> foods;
  final bool isLoading;
  final String? error;
  final Function(FoodTrackingEntry) onAdd;
  final Function(FoodTrackingEntry) onUpdate;
  final Function(Food) onAddFood;
  final Function(Food) onUpdateFood;
  final Function(String) onDeleteFood;
  final Function() clearError;

  _ViewModel({
    required this.foods,
    required this.isLoading,
    required this.error,
    required this.onAdd,
    required this.onUpdate,
    required this.onAddFood,
    required this.onUpdateFood,
    required this.onDeleteFood,
    required this.clearError,
  });

  static _ViewModel fromStore(Store<AppState> store, String petId) {
    return _ViewModel(
      foods: store.state.food.foods,
      isLoading: store.state.food.isLoading,
      error: store.state.food.error,
      onAdd: (entry) => store.dispatch(AddFoodTrackingEntry(petId, entry, optimistic: true)),
      onUpdate: (entry) => store.dispatch(UpdateFoodTrackingEntry(petId, entry, optimistic: true)),
      onAddFood: (food) => store.dispatch(AddFoodAction(food)),
      onUpdateFood: (food) => store.dispatch(UpdateFoodAction(food)),
      onDeleteFood: (foodId) => store.dispatch(DeleteFoodAction(foodId)),
      clearError: () => store.dispatch(ClearFoodTrackingError(petId)),
    );
  }
} 