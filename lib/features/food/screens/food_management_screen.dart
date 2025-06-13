import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../core/store/app_state.dart';
import '../models/food.dart';
import '../store/food_actions.dart';
import '../store/food_state.dart';

class FoodManagementScreen extends StatelessWidget {
  const FoodManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) {
        store.dispatch(LoadFoodsAction(
          store.state.auth.userId!,
        ));
      },
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Foods'),
            actions: [
              if (vm.isPendingSync)
                const Tooltip(
                  message: 'Changes will sync when online',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.sync, color: Colors.orange),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Foods',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    vm.onSearch(value);
                  },
                ),
              ),
              Expanded(
                child: vm.isLoading && vm.foods.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : vm.error != null && vm.foods.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error loading foods',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(vm.error!),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: vm.onRetry,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: vm.filteredFoods.length,
                            itemBuilder: (context, index) {
                              final food = vm.filteredFoods[index];
                              return _FoodListItem(
                                food: food,
                                onEdit: () => _showFoodDialog(context, food),
                                onDelete: () => _showDeleteDialog(context, food, vm),
                              );
                            },
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showFoodDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _showFoodDialog(BuildContext context, [Food? existingFood]) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existingFood?.name);
    var selectedType = existingFood?.type ?? FoodType.dry;
    final kCalController = TextEditingController(
      text: existingFood?.kCalPerGram?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingFood == null ? 'Add Food' : 'Edit Food'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FoodType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  border: OutlineInputBorder(),
                ),
                items: FoodType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: kCalController,
                decoration: const InputDecoration(
                  labelText: 'Calories per gram',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = double.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final food = Food(
                  id: existingFood?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  type: selectedType,
                  kCalPerGram: kCalController.text.isNotEmpty
                      ? double.parse(kCalController.text)
                      : null,
                  createdAt: existingFood?.createdAt ?? DateTime.now(),
                  createdBy: existingFood?.createdBy ?? (StoreProvider.of<dynamic>(context).state as dynamic).auth.userId,
                  updatedAt: existingFood != null ? DateTime.now() : null,
                );

                if (existingFood != null) {
                  StoreProvider.of<dynamic>(context).dispatch(
                    UpdateFoodAction(food, optimistic: true),
                  );
                } else {
                  StoreProvider.of<dynamic>(context).dispatch(
                    AddFoodAction(food, optimistic: true),
                  );
                }

                Navigator.of(context).pop();
              }
            },
            child: Text(existingFood == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Food food, _ViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food'),
        content: Text('Are you sure you want to delete ${food.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      vm.onDelete(food.id);
    }
  }
}

class _FoodListItem extends StatelessWidget {
  final Food food;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FoodListItem({
    Key? key,
    required this.food,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(food.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(food.type.toString().split('.').last),
          if (food.kCalPerGram != null)
            Text('${food.kCalPerGram} kcal/g'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ViewModel {
  final List<Food> foods;
  final List<Food> filteredFoods;
  final bool isLoading;
  final bool isPendingSync;
  final String? error;
  final Function(String) onSearch;
  final Function() onRetry;
  final Function(String) onDelete;

  _ViewModel({
    required this.foods,
    required this.filteredFoods,
    required this.isLoading,
    required this.isPendingSync,
    this.error,
    required this.onSearch,
    required this.onRetry,
    required this.onDelete,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    final state = store.state.food;

    return _ViewModel(
      foods: state.foods,
      filteredFoods: state.foods, // TODO: Implement filtering
      isLoading: state.isLoading,
      isPendingSync: state.isPendingSyncById.values.any((isPending) => isPending),
      error: state.error,
      onSearch: (query) {
        store.dispatch(SearchFoodsAction(query));
      },
      onRetry: () {
        store.dispatch(LoadFoodsAction(
          store.state.auth.userId!,
        ));
      },
      onDelete: (foodId) {
        store.dispatch(DeleteFoodAction(foodId, optimistic: true));
      },
    );
  }
} 