import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/store/app_state.dart';
import '../models/health_entry.dart';
import '../store/health_actions.dart';
import 'health_entry_modal.dart';

class HealthTimeline extends StatefulWidget {
  final String petId;

  const HealthTimeline({
    super.key,
    required this.petId,
  });

  @override
  State<HealthTimeline> createState() => _HealthTimelineState();
}

class _HealthTimelineState extends State<HealthTimeline> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchTerm = '';
  String _filterType = 'all'; // 'all', 'temperature', 'file', 'combined'

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
      _loadEntries();
    }
  }

  void _loadEntries() {
    Store<AppState> store = StoreProvider.of<AppState>(context);
    
    if (_startDate != null && _endDate != null) {
      store.dispatch(LoadHealthEntriesInDateRangeAction(
        petId: widget.petId,
        startDate: _startDate,
        endDate: _endDate,
      ));
    } else if (_filterType == 'temperature') {
      store.dispatch(LoadTemperatureEntriesAction(petId: widget.petId));
    } else if (_filterType == 'file') {
      store.dispatch(LoadFileEntriesAction(petId: widget.petId));
    } else if (_searchTerm.isNotEmpty) {
      store.dispatch(SearchHealthEntriesAction(
        petId: widget.petId,
        searchTerm: _searchTerm,
      ));
    } else {
      store.dispatch(LoadHealthEntriesAction(petId: widget.petId));
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _searchTerm = '';
      _filterType = 'all';
    });
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) {
        store.dispatch(LoadHealthEntriesAction(petId: widget.petId));
      },
      converter: (store) => _ViewModel.fromStore(store, widget.petId),
      builder: (context, vm) {
        Widget content;
        
        if (vm.isLoading) {
          content = const Center(child: CircularProgressIndicator());
        } else if (vm.error != null) {
          content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(vm.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadEntries(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (vm.entriesByDate.isEmpty) {
          content = const Center(
            child: Text('No health entries yet. Add your first health record!'),
          );
        } else {
          content = ListView.builder(
            itemCount: vm.entriesByDate.length,
            itemBuilder: (context, index) {
              final date = vm.entriesByDate.keys.elementAt(index);
              final entries = vm.entriesByDate[date]!;
              return _DaySection(
                date: date,
                entries: entries,
                onEdit: (entry) => _showEntryModal(context, entry),
                onDelete: vm.deleteHealthEntry,
              );
            },
          );
        }

        return Column(
          children: [
            // Filter Controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Date Range Filter
                  Row(
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
                      if (_startDate != null || _filterType != 'all' || _searchTerm.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearFilters,
                          tooltip: 'Clear filters',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Type Filter and Search
                  Row(
                    children: [
                      // Type Filter Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _filterType,
                          decoration: const InputDecoration(
                            labelText: 'Filter by type',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All entries')),
                            DropdownMenuItem(value: 'temperature', child: Text('Temperature only')),
                            DropdownMenuItem(value: 'file', child: Text('Health records')),
                            DropdownMenuItem(value: 'combined', child: Text('Combined entries')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _filterType = value ?? 'all';
                            });
                            _loadEntries();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Search Button
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _showSearchDialog(context),
                        tooltip: 'Search notes',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
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

  void _showEntryModal(BuildContext context, [HealthEntry? existingEntry]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => HealthEntryModal(
        petId: widget.petId,
        entry: existingEntry,
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Health Entries'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Search in notes',
            hintText: 'Enter search term...',
          ),
          onChanged: (value) {
            setState(() {
              _searchTerm = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadEntries();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime date;
  final List<HealthEntry> entries;
  final Function(HealthEntry) onEdit;
  final Function(String) onDelete;

  const _DaySection({
    super.key,
    required this.date,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });

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
        ...entries.map((entry) => _HealthEntryListItem(
              entry: entry,
              onEdit: () => onEdit(entry),
              onDelete: () => _showDeleteDialog(context, entry),
            )),
        const Divider(height: 1),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, HealthEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Health Entry'),
        content: const Text('Are you sure you want to delete this health entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(entry.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _HealthEntryListItem extends StatelessWidget {
  final HealthEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HealthEntryListItem({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  bool get hasFile => entry.fileUrl != null;
  bool get hasTemperature => entry.temperature != null;

  bool get isImageFile {
    if (!hasFile) return false;
    final url = entry.fileUrl!.toLowerCase();
    return url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png');
  }

  bool get isPdfFile {
    if (!hasFile) return false;
    final url = entry.fileUrl!.toLowerCase();
    return url.endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Temperature-only: hasTemperature && !hasFile
    final isTemperatureOnly = hasTemperature && !hasFile;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isTemperatureOnly
              ? _TemperatureEntryContent(
                  entry: entry,
                  onEdit: onEdit,
                  onDelete: onDelete,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timestamp at the top
                    Text(
                      DateFormat('h:mm a').format(entry.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    // File preview (if present)
                    if (hasFile)
                      GestureDetector(
                        onTap: () => _openFile(context),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isImageFile)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  entry.fileUrl!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
                                ),
                              )
                            else if (isPdfFile)
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                              )
                            else
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.insert_drive_file, color: Colors.blueGrey, size: 32),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getFileName(entry.fileUrl!),
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.open_in_new, size: 18, color: Colors.blueGrey),
                          ],
                        ),
                      ),
                    if (hasFile) const SizedBox(height: 8),
                    // Entry type indicator and content
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Entry type icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getEntryTypeColor(hasFile, hasTemperature).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getEntryTypeIcon(hasFile, hasTemperature),
                            color: _getEntryTypeColor(hasFile, hasTemperature),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Entry content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Entry type label
                              Text(
                                _getEntryTypeLabel(hasFile, hasTemperature),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _getEntryTypeColor(hasFile, hasTemperature),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Temperature value (if present)
                              if (hasTemperature)
                                Text(
                                  'Temperature: ${entry.temperature!.toStringAsFixed(1)}°C',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              // Notes (if present)
                              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  entry.notes!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
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

  void _openFile(BuildContext context) async {
    if (isImageFile) {
      showDialog(
        context: context,
        builder: (context) => _ImagePreviewDialog(imageUrl: entry.fileUrl!),
      );
    } else if (isPdfFile) {
      // For now, open PDF in browser
      final url = entry.fileUrl!;
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } else if (hasFile) {
      // Fallback: open in browser
      final url = entry.fileUrl!;
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  IconData _getEntryTypeIcon(bool hasFile, bool hasTemperature) {
    if (hasFile && hasTemperature) {
      return Icons.medical_services;
    } else if (hasFile) {
      return Icons.file_upload;
    } else if (hasTemperature) {
      return Icons.thermostat;
    } else {
      return Icons.medical_services;
    }
  }

  Color _getEntryTypeColor(bool hasFile, bool hasTemperature) {
    if (hasFile && hasTemperature) {
      return Colors.purple;
    } else if (hasFile) {
      return Colors.blue;
    } else if (hasTemperature) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  String _getEntryTypeLabel(bool hasFile, bool hasTemperature) {
    if (hasFile && hasTemperature) {
      return 'Health Record + Temperature';
    } else if (hasFile) {
      return 'Health Record';
    } else if (hasTemperature) {
      return 'Temperature Log';
    } else {
      return 'Health Entry';
    }
  }

  String _getFileName(String fileUrl) {
    try {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        // Remove any query parameters or fragments
        return fileName.split('?').first.split('#').first;
      }
    } catch (e) {
      // If parsing fails, return a generic name
    }
    return 'Health Record';
  }
}

class _TemperatureEntryContent extends StatelessWidget {
  final HealthEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const _TemperatureEntryContent({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.thermostat, color: Colors.orange, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              '${entry.temperature?.toStringAsFixed(1) ?? '--'}°C',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.orange[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('h:mm a').format(entry.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
        ),
        if (entry.notes != null && entry.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            entry.notes!,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
    );
  }
}

class _ImagePreviewDialog extends StatelessWidget {
  final String imageUrl;
  const _ImagePreviewDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 120),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final String? error;
  final Map<DateTime, List<HealthEntry>> entriesByDate;
  final Function() loadHealthEntries;
  final Function(String) deleteHealthEntry;
  final Function(DateTime?, DateTime?) loadHealthEntriesInDateRange;
  final Function() loadTemperatureEntries;
  final Function() loadFileEntries;
  final Function(String) searchHealthEntries;
  final Function() loadHealthEntryStats;

  _ViewModel({
    required this.isLoading,
    required this.error,
    required this.entriesByDate,
    required this.loadHealthEntries,
    required this.deleteHealthEntry,
    required this.loadHealthEntriesInDateRange,
    required this.loadTemperatureEntries,
    required this.loadFileEntries,
    required this.searchHealthEntries,
    required this.loadHealthEntryStats,
  });

  factory _ViewModel.fromStore(Store<AppState> store, String petId) {
    final state = store.state.health;
    final entries = state.getEntriesForPet(petId);

    // Group entries by date
    final entriesByDate = <DateTime, List<HealthEntry>>{};
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
      loadHealthEntries: () => store.dispatch(LoadHealthEntriesAction(petId: petId)),
      deleteHealthEntry: (entryId) => store.dispatch(DeleteHealthEntryAction(entryId: entryId)),
      loadHealthEntriesInDateRange: (startDate, endDate) => store.dispatch(
        LoadHealthEntriesInDateRangeAction(
          petId: petId,
          startDate: startDate,
          endDate: endDate,
        ),
      ),
      loadTemperatureEntries: () => store.dispatch(LoadTemperatureEntriesAction(petId: petId)),
      loadFileEntries: () => store.dispatch(LoadFileEntriesAction(petId: petId)),
      searchHealthEntries: (searchTerm) => store.dispatch(
        SearchHealthEntriesAction(petId: petId, searchTerm: searchTerm),
      ),
      loadHealthEntryStats: () => store.dispatch(LoadHealthEntryStatsAction(petId: petId)),
    );
  }
} 