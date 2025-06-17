import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../core/store/app_state.dart';
import '../models/measurement_entry.dart';
import '../store/measurement_actions.dart';
import '../store/measurement_state.dart';

class MeasurementLogsScreen extends StatelessWidget {
  final String petId;

  const MeasurementLogsScreen({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (Store<AppState> store) => _ViewModel.fromStore(store, petId),
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Measurements'),
          ),
          body: _buildBody(context, vm),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddMeasurementDialog(context, vm),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, _ViewModel vm) {
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

    if (vm.entries.isEmpty) {
      return const Center(
        child: Text('No measurements yet. Add your first measurement!'),
      );
    }

    return ListView.builder(
      itemCount: vm.entries.length,
      itemBuilder: (context, index) {
        final entry = vm.entries[index];
        return ListTile(
          title: Text('${entry.type}: ${entry.value} ${entry.unit}'),
          subtitle: Text(entry.timestamp.toString()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditMeasurementDialog(context, vm, entry),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context, vm, entry),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMeasurementDialog(BuildContext context, _ViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => _MeasurementDialog(
        onSave: (type, value, unit, notes) {
          final entry = MeasurementEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            petId: petId,
            type: type,
            value: value,
            unit: unit,
            timestamp: DateTime.now(),
            notes: notes,
          );
          vm.addMeasurement(entry);
        },
      ),
    );
  }

  void _showEditMeasurementDialog(
    BuildContext context,
    _ViewModel vm,
    MeasurementEntry entry,
  ) {
    showDialog(
      context: context,
      builder: (context) => _MeasurementDialog(
        initialType: entry.type,
        initialValue: entry.value,
        initialUnit: entry.unit,
        initialNotes: entry.notes,
        onSave: (type, value, unit, notes) {
          final updatedEntry = entry.copyWith(
            type: type,
            value: value,
            unit: unit,
            notes: notes,
          );
          vm.editMeasurement(updatedEntry);
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    _ViewModel vm,
    MeasurementEntry entry,
  ) {
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
              vm.deleteMeasurement(entry.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MeasurementDialog extends StatefulWidget {
  final String? initialType;
  final double? initialValue;
  final String? initialUnit;
  final String? initialNotes;
  final Function(String type, double value, String unit, String? notes) onSave;

  const _MeasurementDialog({
    Key? key,
    this.initialType,
    this.initialValue,
    this.initialUnit,
    this.initialNotes,
    required this.onSave,
  }) : super(key: key);

  @override
  _MeasurementDialogState createState() => _MeasurementDialogState();
}

class _MeasurementDialogState extends State<_MeasurementDialog> {
  late final TextEditingController _typeController;
  late final TextEditingController _valueController;
  late final TextEditingController _unitController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.initialType);
    _valueController = TextEditingController(
      text: widget.initialValue?.toString(),
    );
    _unitController = TextEditingController(text: widget.initialUnit);
    _notesController = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _typeController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialType == null ? 'Add Measurement' : 'Edit Measurement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type (e.g., weight, height, length)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Unit (e.g., kg, cm)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
              ),
              maxLines: 3,
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
          onPressed: () {
            final type = _typeController.text;
            final value = double.tryParse(_valueController.text) ?? 0.0;
            final unit = _unitController.text;
            final notes = _notesController.text.isEmpty ? null : _notesController.text;

            if (type.isEmpty || value <= 0 || unit.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all required fields'),
                ),
              );
              return;
            }

            widget.onSave(type, value, unit, notes);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final String? error;
  final List<MeasurementEntry> entries;
  final Function() loadMeasurements;
  final Function(MeasurementEntry) addMeasurement;
  final Function(MeasurementEntry) editMeasurement;
  final Function(String) deleteMeasurement;

  _ViewModel({
    required this.isLoading,
    required this.error,
    required this.entries,
    required this.loadMeasurements,
    required this.addMeasurement,
    required this.editMeasurement,
    required this.deleteMeasurement,
  });

  factory _ViewModel.fromStore(Store<AppState> store, String petId) {
    final state = store.state.measurements;
    final entries = state.getEntriesForPet(petId);

    return _ViewModel(
      isLoading: state.isLoading,
      error: state.error,
      entries: entries,
      loadMeasurements: () => store.dispatch(LoadMeasurementsAction(petId)),
      addMeasurement: (entry) => store.dispatch(AddMeasurementAction(petId, entry)),
      editMeasurement: (entry) => store.dispatch(EditMeasurementAction(petId, entry)),
      deleteMeasurement: (entryId) => store.dispatch(DeleteMeasurementAction(petId, entryId)),
    );
  }
} 