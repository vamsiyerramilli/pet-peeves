import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:intl/intl.dart';
import '../../../core/store/app_state.dart';
import '../models/food_tracking_entry.dart';
import '../store/food_actions.dart';
import '../store/food_tracking_state.dart';
import '../widgets/food_entry_modal.dart';

class FoodTrackingScreen extends StatelessWidget {
  final String petId;

  const FoodTrackingScreen({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) {
        store.dispatch(LoadFoodEntriesAction(petId));
      },
      converter: (store) => _ViewModel.fromStore(store, petId),
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Food Tracking'),
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
          body: vm.isLoading && vm.entriesByDate.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : vm.error != null && vm.entriesByDate.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error loading food entries',
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
                      itemCount: vm.entriesByDate.length,
                      itemBuilder: (context, index) {
                        final date = vm.entriesByDate.keys.elementAt(index);
                        final entries = vm.entriesByDate[date]!;
                        return _DaySection(
                          date: date,
                          entries: entries,
                          onEdit: (entry) => _showEntryModal(context, entry),
                          onDelete: vm.onDelete,
                          isPendingSync: vm.isEntryPending,
                        );
                      },
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showEntryModal(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showEntryModal(BuildContext context, [FoodTrackingEntry? existingEntry]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FoodEntryModal(
        petId: petId,
        entry: existingEntry,
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime date;
  final List<FoodTrackingEntry> entries;
  final Function(FoodTrackingEntry) onEdit;
  final Function(String, String) onDelete;
  final Function(String, String) isPendingSync;

  const _DaySection({
    Key? key,
    required this.date,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
    required this.isPendingSync,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalCalories = entries
        .map((e) => e.kCal ?? 0)
        .fold<double>(0, (sum, cal) => sum + cal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (totalCalories > 0)
                Text(
                  '${totalCalories.toStringAsFixed(1)} kcal',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
            ],
          ),
        ),
        ...entries.map((entry) => _FoodEntryListItem(
              entry: entry,
              onEdit: () => onEdit(entry),
              onDelete: () => _showDeleteDialog(context, entry),
              isPendingSync: isPendingSync(entry.petId, entry.id),
            )),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, FoodTrackingEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete this food entry?'),
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
      onDelete(entry.petId, entry.id);
    }
  }
}

class _FoodEntryListItem extends StatelessWidget {
  final FoodTrackingEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isPendingSync;

  const _FoodEntryListItem({
    Key? key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    required this.isPendingSync,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(entry.foodName),
          if (isPendingSync)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Tooltip(
                message: 'Changes will sync when online',
                child: Icon(Icons.sync, color: Colors.orange, size: 16),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('h:mm a').format(entry.timestamp)),
          Text('${entry.weightGrams}g ${entry.type.toString().split('.').last}'),
          if (entry.kCal != null)
            Text('${entry.kCal!.toStringAsFixed(1)} kcal'),
          if (entry.notes != null)
            Text(
              entry.notes!,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
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
  final Map<DateTime, List<FoodTrackingEntry>> entriesByDate;
  final bool isLoading;
  final bool isPendingSync;
  final String? error;
  final Function() onRetry;
  final Function(String, String) onDelete;
  final Function(String, String) isEntryPending;

  _ViewModel({
    required this.entriesByDate,
    required this.isLoading,
    required this.isPendingSync,
    this.error,
    required this.onRetry,
    required this.onDelete,
    required this.isEntryPending,
  });

  static _ViewModel fromStore(Store<AppState> store, String petId) {
    final state = store.state.foodTracking;

    return _ViewModel(
      entriesByDate: state.getEntriesGroupedByDate(petId),
      isLoading: state.isLoading,
      isPendingSync: state.pendingSyncByPetId[petId]?.values.any((isPending) => isPending) ?? false,
      error: state.error,
      onRetry: () {
        store.dispatch(LoadFoodEntriesAction(petId));
      },
      onDelete: (petId, entryId) {
        store.dispatch(DeleteFoodEntryAction(
          petId,
          entryId,
          optimistic: true,
        ));
      },
      isEntryPending: (petId, entryId) {
        return state.isEntryPending(petId, entryId);
      },
    );
  }
} 