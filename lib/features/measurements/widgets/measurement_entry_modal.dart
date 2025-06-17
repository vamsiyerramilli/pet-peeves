import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:intl/intl.dart';
import '../../../core/store/app_state.dart';
import '../models/measurement_entry.dart';
import '../store/measurement_actions.dart';

class MeasurementEntryModal extends StatefulWidget {
  final String petId;
  final MeasurementEntry? entry;

  const MeasurementEntryModal({
    Key? key,
    required this.petId,
    this.entry,
  }) : super(key: key);

  @override
  _MeasurementEntryModalState createState() => _MeasurementEntryModalState();
}

class _MeasurementEntryModalState extends State<MeasurementEntryModal> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _timestamp;
  double? _weightKg;
  double? _heightCm;
  double? _lengthCm;
  String? _notes;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _timestamp = widget.entry!.timestamp;
      _weightKg = widget.entry!.weightKg;
      _heightCm = widget.entry!.heightCm;
      _lengthCm = widget.entry!.lengthCm;
      _notes = widget.entry!.notes;
    } else {
      _timestamp = DateTime.now();
    }
  }

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_timestamp);
  String get _formattedTime => DateFormat('HH:mm').format(_timestamp);

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) return null;
    final weight = double.tryParse(value);
    if (weight == null) return 'Enter a valid number';
    if (weight <= 0) return 'Weight must be greater than 0';
    if (weight < 0.01) return 'Minimum weight is 0.01 kg';
    if (weight > 1000) return 'Maximum weight is 1000 kg';
    return null;
  }

  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) return null;
    final height = double.tryParse(value);
    if (height == null) return 'Enter a valid number';
    if (height <= 0) return 'Height must be greater than 0';
    if (height < 1) return 'Minimum height is 1 cm';
    if (height > 10000) return 'Maximum height is 10000 cm';
    return null;
  }

  String? _validateLength(String? value) {
    if (value == null || value.isEmpty) return null;
    final length = double.tryParse(value);
    if (length == null) return 'Enter a valid number';
    if (length <= 0) return 'Length must be greater than 0';
    if (length < 1) return 'Minimum length is 1 cm';
    if (length > 10000) return 'Maximum length is 10000 cm';
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _timestamp = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _timestamp.hour,
          _timestamp.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (picked != null) {
      setState(() {
        _timestamp = DateTime(
          _timestamp.year,
          _timestamp.month,
          _timestamp.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      if (_weightKg == null && _heightCm == null && _lengthCm == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter at least one measurement.')),
        );
        return;
      }

      final now = DateTime.now();
      final entry = widget.entry?.copyWith(
        timestamp: _timestamp,
        weightKg: _weightKg,
        heightCm: _heightCm,
        lengthCm: _lengthCm,
        notes: _notes,
        updatedAt: now,
      ) ?? MeasurementEntry(
        id: '', // Will be set by backend/service
        petId: widget.petId,
        timestamp: _timestamp,
        weightKg: _weightKg,
        heightCm: _heightCm,
        lengthCm: _lengthCm,
        notes: _notes,
        createdAt: now,
      );

      StoreProvider.of<AppState>(context).dispatch(
        widget.entry != null 
          ? EditMeasurementAction(entry.petId, entry)
          : AddMeasurementAction(entry.petId, entry)
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.entry != null ? 'Edit Measurement' : 'Add Measurement'),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'When was this measurement taken?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_formattedDate),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _selectTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(_formattedTime),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Measurements',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Semantics(
              label: 'Weight in kilograms',
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Weight',
                  helperText: 'Range: 0.01 - 1000 kg',
                  errorStyle: const TextStyle(height: 0.8),
                  suffixText: 'kg',
                  suffixStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                initialValue: _weightKg?.toString(),
                validator: _validateWeight,
                onSaved: (val) => _weightKg = double.tryParse(val ?? ''),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Height in centimeters',
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Height',
                  helperText: 'Range: 1 - 10000 cm',
                  errorStyle: const TextStyle(height: 0.8),
                  suffixText: 'cm',
                  suffixStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                initialValue: _heightCm?.toString(),
                validator: _validateHeight,
                onSaved: (val) => _heightCm = double.tryParse(val ?? ''),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Length in centimeters',
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Length',
                  helperText: 'Range: 1 - 10000 cm',
                  errorStyle: const TextStyle(height: 0.8),
                  suffixText: 'cm',
                  suffixStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                initialValue: _lengthCm?.toString(),
                validator: _validateLength,
                onSaved: (val) => _lengthCm = double.tryParse(val ?? ''),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Additional Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Semantics(
              label: 'Optional notes',
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Notes',
                  helperText: 'Optional',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                initialValue: _notes,
                onSaved: (val) => _notes = val,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 