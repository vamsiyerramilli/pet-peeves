import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:intl/intl.dart';
import '../../../core/store/app_state.dart';
import '../models/food_tracking_entry.dart';
import '../store/food_tracking_actions.dart';
import '../widgets/food_entry_modal.dart';

class FoodTimeline extends StatefulWidget {
  final String petId;

  const FoodTimeline({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  State<FoodTimeline> createState() => _FoodTimelineState();
}

class _FoodTimelineState extends State<FoodTimeline> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: _endDate ?? DateTime.now(),
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) => _loadEntries(),
      onDidChange: (_ViewModel? prev, _ViewModel next) {
        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: next.onRetry,
                textColor: Colors.white,
              ),
            ),
          );
        }
      },
      converter: (store) => _ViewModel.fromStore(store, widget.petId, context),
      builder: (context, vm) {
        Widget content;

        if (vm.isLoading && vm.entries.isEmpty) {
          content = const Center(child: CircularProgressIndicator());
        } else if (vm.error != null && vm.entries.isEmpty) {
          content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading food entries',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  vm.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: vm.onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (vm.entries.isEmpty) {
          content = Center(
            child: Text(
              'No food entries yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        } else {
          // Group entries by date
          final groupedEntries = _groupEntriesByDate(vm.entries);

          content = ListView.builder(
            itemCount: groupedEntries.length,
            itemBuilder: (context, index) {
              final date = groupedEntries.keys.elementAt(index);
              final entries = groupedEntries[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _formatDate(date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...entries.map((entry) => _FoodEntryCard(
                        entry: entry,
                        onEdit: () => vm.onEditEntry(entry),
                        onDelete: () => _showDeleteConfirmation(context, vm, entry),
                        isPendingSync: vm.isPendingSync(entry.id),
                      )),
                ],
              );
            },
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDateRange(context),
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _startDate != null && _endDate != null
                            ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'
                            : 'Filter by date',
                      ),
                    ),
                  ),
                  if (_startDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                        _loadEntries();
                      },
                      tooltip: 'Clear filter',
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadEntries();
                },
                child: content,
              ),
            ),
          ],
        );
      },
    );
  }

  void _loadEntries() {
    Store<AppState> store = StoreProvider.of<AppState>(context);
    store.dispatch(LoadFoodTrackingEntries(widget.petId));
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    _ViewModel vm,
    FoodTrackingEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: Text(
          'Are you sure you want to delete the food entry for ${entry.foodName}?'
          '\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      vm.onDeleteEntry(entry.id);
    }
  }

  Map<DateTime, List<FoodTrackingEntry>> _groupEntriesByDate(List<FoodTrackingEntry> entries) {
    final grouped = <DateTime, List<FoodTrackingEntry>>{};
    
    for (var entry in entries) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(entry);
    }

    // Sort dates in descending order
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!..sort((a, b) => b.timestamp.compareTo(a.timestamp)))),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }
}

class _FoodEntryCard extends StatelessWidget {
  final FoodTrackingEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isPendingSync;

  const _FoodEntryCard({
    Key? key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    required this.isPendingSync,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Food entry for ${entry.foodName}',
      value: '${entry.weightGrams}g at ${DateFormat.jm().format(entry.timestamp)}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.jm().format(entry.timestamp),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (isPendingSync)
                    const Tooltip(
                      message: 'Syncing...',
                      child: Icon(Icons.sync, color: Colors.orange),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.foodName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${entry.weightGrams}g',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  if (entry.kCal != null)
                    Text(
                      '${entry.kCal!.toStringAsFixed(1)} kcal',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
              if (entry.notes != null) ...[
                const SizedBox(height: 8),
                Text(
                  entry.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                    tooltip: 'Edit entry',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                    tooltip: 'Delete entry',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModel {
  final List<FoodTrackingEntry> entries;
  final bool isLoading;
  final String? error;
  final Function() onRetry;
  final Function(FoodTrackingEntry) onEditEntry;
  final Function(String) onDeleteEntry;
  final Function(String) isPendingSync;

  _ViewModel({
    required this.entries,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onEditEntry,
    required this.onDeleteEntry,
    required this.isPendingSync,
  });

  static _ViewModel fromStore(Store<AppState> store, String petId, BuildContext context) {
    return _ViewModel(
      entries: store.state.foodTracking.getEntriesForPet(petId),
      isLoading: store.state.foodTracking.isLoading,
      error: store.state.foodTracking.error,
      onRetry: () => store.dispatch(LoadFoodTrackingEntries(petId)),
      onEditEntry: (entry) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => FoodEntryModal(
            petId: petId,
            entry: entry,
          ),
        );
      },
      onDeleteEntry: (entryId) => store.dispatch(DeleteFoodTrackingEntry(petId, entryId)),
      isPendingSync: (entryId) => store.state.foodTracking.isEntryPending(petId, entryId),
    );
  }
} 