import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../core/store/app_state.dart';
import '../models/health_entry.dart';
import '../store/health_actions.dart';

enum HealthEntryType {
  healthRecord,
  temperature,
}

class HealthEntryModal extends StatefulWidget {
  final HealthEntry? entry; // Optional for edit mode
  final String petId;
  final VoidCallback? onSave;

  const HealthEntryModal({
    super.key,
    this.entry,
    required this.petId,
    this.onSave,
  });

  @override
  State<HealthEntryModal> createState() => _HealthEntryModalState();
}

class _HealthEntryModalState extends State<HealthEntryModal> {
  final _formKey = GlobalKey<FormState>();
  final _temperatureController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  HealthEntryType _selectedEntryType = HealthEntryType.healthRecord;
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedFileName;
  String? _selectedFileUrl;

  @override
  void initState() {
    super.initState();
    
    // Handle edit mode - pre-fill form with existing data
    if (widget.entry != null) {
      final entry = widget.entry!;
      
      // Pre-fill timestamp
      _selectedDateTime = entry.timestamp;
      
      // Pre-fill notes
      _notesController.text = entry.notes ?? '';
      
      // Determine entry type and pre-fill relevant data
      if (entry.fileUrl != null) {
        // Health Record entry
        _selectedEntryType = HealthEntryType.healthRecord;
        _selectedFileUrl = entry.fileUrl;
        _selectedFileName = _extractFileNameFromUrl(entry.fileUrl!);
      } else if (entry.temperature != null) {
        // Temperature entry
        _selectedEntryType = HealthEntryType.temperature;
        _temperatureController.text = entry.temperature!.toString();
      } else {
        // Fallback: determine type based on available data
        // This handles edge cases where both might be null
        _selectedEntryType = HealthEntryType.healthRecord;
      }
    }
  }

  String _extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        // Remove query parameters if present
        final cleanFileName = fileName.split('?').first;
        if (cleanFileName.isNotEmpty) {
          return cleanFileName;
        }
      }
      
      // Fallback: try to extract from the last part of the path
      final pathParts = url.split('/');
      if (pathParts.isNotEmpty) {
        final lastPart = pathParts.last.split('?').first;
        if (lastPart.isNotEmpty && lastPart.contains('.')) {
          return lastPart;
        }
      }
      
      // Final fallback based on URL content
      if (url.contains('.pdf')) {
        return 'Health Record.pdf';
      } else if (url.contains('.jpg') || url.contains('.jpeg')) {
        return 'Health Record.jpg';
      } else if (url.contains('.png')) {
        return 'Health Record.png';
      } else {
        return 'Health Record';
      }
    } catch (e) {
      // If URL parsing fails, return a generic name
      return 'Health Record';
    }
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.entry != null;
    final title = isEditMode ? 'Edit Health Entry' : 'Add Health Entry';

    return WillPopScope(
      onWillPop: () async {
        _handleClose();
        return false; // Let _handleClose handle the navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleClose,
          ),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton(
                onPressed: _isFormValid() ? _handleSave : null,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: _isFormValid() 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entry Type Selection
                _buildEntryTypeSection(),
                
                const SizedBox(height: 24),
                
                // File Upload Section (conditional)
                if (_selectedEntryType == HealthEntryType.healthRecord) ...[
                  _buildFileUploadSection(),
                  const SizedBox(height: 24),
                ],
                
                // Temperature Section (conditional)
                if (_selectedEntryType == HealthEntryType.temperature) ...[
                  _buildTemperatureSection(),
                  const SizedBox(height: 24),
                ],
                
                // Notes Section
                _buildNotesSection(),
                
                const SizedBox(height: 24),
                
                // Date/Time Section
                _buildDateTimeSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryTypeSection() {
    final isEditMode = widget.entry != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Entry Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isEditMode) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text(
                  'Edit Mode',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isEditMode 
            ? 'Modify the entry type or update the information below'
            : 'Choose what type of health information you want to log',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<HealthEntryType>(
          segments: const [
            ButtonSegment<HealthEntryType>(
              value: HealthEntryType.healthRecord,
              label: Text('Health Record'),
              icon: Icon(Icons.file_upload),
            ),
            ButtonSegment<HealthEntryType>(
              value: HealthEntryType.temperature,
              label: Text('Temperature'),
              icon: Icon(Icons.thermostat),
            ),
          ],
          selected: {_selectedEntryType},
          onSelectionChanged: (Set<HealthEntryType> newSelection) {
            setState(() {
              _selectedEntryType = newSelection.first;
            });
            // Trigger form validation update
            if (_formKey.currentState != null) {
              _formKey.currentState!.validate();
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context).primaryColor.withOpacity(0.1);
                }
                return Colors.transparent;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Record',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload a photo or PDF of your pet\'s health record',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        
        // File Upload Area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedFileName != null ? Colors.green : Colors.grey.shade400,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _selectedFileName != null ? Colors.green.withOpacity(0.05) : Colors.grey.shade50,
          ),
          child: Column(
            children: [
              if (_selectedFileName != null) ...[
                // File Selected State
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedFileName!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'File uploaded successfully',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Change File'),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: _removeFile,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Remove', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ] else ...[
                // No File Selected State
                const Icon(
                  Icons.cloud_upload,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No file selected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap to select a photo or PDF file',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Select File'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // File Requirements
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'File Requirements',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '• Supported formats: JPG, PNG, PDF\n'
                '• Maximum file size: 10MB\n'
                '• Clear, readable images recommended',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temperature',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your pet\'s temperature',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _temperatureController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Temperature',
            hintText: 'e.g., 38.5',
            suffixText: '°C',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.thermostat),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a temperature';
            }
            final temperature = double.tryParse(value);
            if (temperature == null) {
              return 'Please enter a valid number';
            }
            if (temperature <= 0) {
              return 'Temperature must be greater than 0°C';
            }
            if (temperature < 25 || temperature > 50) {
              return 'Temperature must be between 25°C and 50°C';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'Normal pet temperature range: 37.5°C - 39.2°C',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add any additional notes about this health entry',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'e.g., After exercise, normal behavior...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'When did this health event occur?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _selectDateTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _formatDateTime(_selectedDateTime),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                ]),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateText;
    if (entryDate == today) {
      dateText = 'Today';
    } else if (entryDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeText = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateText at $timeText';
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _pickFile() async {
    // TODO: Implement actual file picking logic in a later ticket
    // For now, simulate file selection
    setState(() {
      _selectedFileName = 'health_record_${DateTime.now().millisecondsSinceEpoch}.pdf';
      _selectedFileUrl = 'https://example.com/files/$_selectedFileName';
    });
  }

  void _removeFile() {
    setState(() {
      _selectedFileName = null;
      _selectedFileUrl = null;
    });
  }

  void _handleClose() {
    // Check if there are unsaved changes
    final hasUnsavedChanges = _hasUnsavedChanges();
    
    if (hasUnsavedChanges) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Are you sure you want to close?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close modal
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      // No unsaved changes, close directly
      Navigator.of(context).pop();
    }
  }

  bool _hasUnsavedChanges() {
    // Check if any form fields have been modified
    if (widget.entry == null) {
      // Create mode - check if any fields have data
      return _temperatureController.text.isNotEmpty ||
             _notesController.text.isNotEmpty ||
             _selectedFileName != null ||
             _selectedDateTime != DateTime.now();
    } else {
      // Edit mode - check if any fields have changed from original
      final original = widget.entry!;
      return _temperatureController.text != (original.temperature?.toString() ?? '') ||
             _notesController.text != (original.notes ?? '') ||
             _selectedDateTime != original.timestamp;
    }
  }

  void _handleSave() async {
    final validationError = _getValidationErrorMessage();
    if (validationError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      // Create the health entry data
      final healthEntryData = _createHealthEntryData();
      // Create HealthEntry object
      final healthEntry = HealthEntry.fromJson(healthEntryData);
      // Get the store and dispatch appropriate action
      final store = StoreProvider.of<AppState>(context);
      if (widget.entry != null) {
        // Edit mode
        store.dispatch(EditHealthEntryAction(
          entryId: widget.entry!.id,
          updatedEntry: healthEntry,
        ));
      } else {
        // Create mode
        store.dispatch(AddHealthEntryAction(entry: healthEntry));
      }
      // Call the onSave callback if provided
      widget.onSave?.call();
      // Close the modal
      Navigator.of(context).pop();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _createHealthEntryData() {
    final isEditMode = widget.entry != null;
    final data = <String, dynamic>{
      'petId': widget.petId,
      'timestamp': _selectedDateTime.toIso8601String(),
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      'createdAt': isEditMode ? widget.entry!.createdAt.toIso8601String() : DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    // Always include id: '' for new entries, or the real id in edit mode
    if (isEditMode) {
      data['id'] = widget.entry!.id;
      if (widget.entry!.createdBy != null) {
        data['createdBy'] = widget.entry!.createdBy;
      }
    } else {
      data['id'] = '';
    }
    
    if (_selectedEntryType == HealthEntryType.healthRecord) {
      data['fileUrl'] = _selectedFileUrl;
      data['temperature'] = null;
    } else if (_selectedEntryType == HealthEntryType.temperature) {
      data['fileUrl'] = null;
      data['temperature'] = double.tryParse(_temperatureController.text.trim());
    }
    
    // Remove nulls for Firestore cleanliness
    data.removeWhere((key, value) => value == null);
    return data;
  }

  bool _isFormValid() {
    if (_selectedEntryType == HealthEntryType.healthRecord) {
      return _selectedFileName != null;
    } else if (_selectedEntryType == HealthEntryType.temperature) {
      final temperatureText = _temperatureController.text.trim();
      final temperature = double.tryParse(temperatureText);
      return temperature != null && temperature >= 25 && temperature <= 50;
    }
    return true;
  }

  String? _getValidationErrorMessage() {
    if (_selectedEntryType == HealthEntryType.healthRecord && _selectedFileName == null) {
      return 'Please select a health record file';
    }
    if (_selectedEntryType == HealthEntryType.temperature) {
      final temperatureText = _temperatureController.text.trim();
      final temperature = double.tryParse(temperatureText);
      if (temperature == null) return 'Please enter a valid temperature';
      if (temperature < 25 || temperature > 50) return 'Temperature must be between 25°C and 50°C';
    }
    return null;
  }
} 