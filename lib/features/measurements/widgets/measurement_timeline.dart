import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:intl/intl.dart';
import '../../../core/store/app_state.dart';
import '../models/measurement_entry.dart';
import '../store/measurement_actions.dart';
import '../store/measurement_state.dart';
import 'measurement_entry_modal.dart';

class MeasurementTimeline extends StatelessWidget {
  final String petId;

  const MeasurementTimeline({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) {
        store.dispatch(LoadMeasurementsAction(petId));
      },
      converter: (store) => _ViewModel.fromStore(store, petId),
      builder: (context, vm) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(vm.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => vm.loadMeasurements(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (vm.entriesByDate.isEmpty) {
          return const Center(
            child: Text('No measurements yet. Add your first measurement!'),
          );
        }

        return ListView.builder(
          itemCount: vm.entriesByDate.length,
          itemBuilder: (context, index) {
            final date = vm.entriesByDate.keys.elementAt(index);
            final entries = vm.entriesByDate[date]!;
            return _DaySection(
              date: date,
              entries: entries,
              onEdit: (entry) => _showEntryModal(context, entry),
              onDelete: vm.deleteMeasurement,
            );
          },
        );
      },
    );
  }

  void _showEntryModal(BuildContext context, [MeasurementEntry? existingEntry]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MeasurementEntryModal(
        petId: petId,
        entry: existingEntry,
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime date;
  final List<MeasurementEntry> entries;
  final Function(MeasurementEntry) onEdit;
  final Function(String, String) onDelete;

  const _DaySection({
    Key? key,
    required this.date,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            DateFormat('EEEE, MMMM d').format(date),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...entries.map((entry) => _MeasurementEntryListItem(
              entry: entry,
              onEdit: () => onEdit(entry),
              onDelete: () => _showDeleteDialog(context, entry),
            )),
        const Divider(height: 1),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, MeasurementEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Measurement'),
        content: const Text('Are you sure you want to delete this measurement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(entry.petId, entry.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MeasurementEntryListItem extends StatelessWidget {
  final MeasurementEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MeasurementEntryListItem({
    Key? key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timestamp at the top
              Text(
                DateFormat('h:mm a').format(entry.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              // Measurements
              if (entry.weightKg != null)
                Text(
                  'Weight: ${entry.weightKg!.toStringAsFixed(1)} kg',
                  style: theme.textTheme.bodyMedium,
                ),
              if (entry.heightCm != null)
                Text(
                  'Height: ${entry.heightCm!.toStringAsFixed(1)} cm',
                  style: theme.textTheme.bodyMedium,
                ),
              if (entry.lengthCm != null)
                Text(
                  'Length: ${entry.lengthCm!.toStringAsFixed(1)} cm',
                  style: theme.textTheme.bodyMedium,
                ),
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.notes!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              // Actions at the bottom right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final String? error;
  final Map<DateTime, List<MeasurementEntry>> entriesByDate;
  final Function() loadMeasurements;
  final Function(String, String) deleteMeasurement;

  _ViewModel({
    required this.isLoading,
    required this.error,
    required this.entriesByDate,
    required this.loadMeasurements,
    required this.deleteMeasurement,
  });

  factory _ViewModel.fromStore(Store<AppState> store, String petId) {
    final state = store.state.measurements;
    final entries = state.getEntriesForPet(petId);

    // Group entries by date
    final entriesByDate = <DateTime, List<MeasurementEntry>>{};
    for (final entry in entries) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      entriesByDate.putIfAbsent(date, () => []).add(entry);
    }

    // Sort entries within each date group by timestamp
    entriesByDate.forEach((date, entries) {
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });

    // Sort dates in descending order
    final sortedDates = entriesByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    final sortedEntriesByDate = Map.fromEntries(
      sortedDates.map((date) => MapEntry(date, entriesByDate[date]!)),
    );

    return _ViewModel(
      isLoading: state.isLoading,
      error: state.error,
      entriesByDate: sortedEntriesByDate,
      loadMeasurements: () => store.dispatch(LoadMeasurementsAction(petId)),
      deleteMeasurement: (petId, entryId) =>
          store.dispatch(DeleteMeasurementAction(petId, entryId)),
    );
  }
} 