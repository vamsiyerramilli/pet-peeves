import 'package:meta/meta.dart';
import '../models/health_entry.dart';

@immutable
class HealthState {
  final List<HealthEntry> entries;
  final bool isLoading;
  final String? error;
  final DateTime? lastSyncedAt;

  const HealthState({
    required this.entries,
    required this.isLoading,
    this.error,
    this.lastSyncedAt,
  });

  factory HealthState.initial() {
    return const HealthState(
      entries: [],
      isLoading: false,
      error: null,
      lastSyncedAt: null,
    );
  }

  HealthState copyWith({
    List<HealthEntry>? entries,
    bool? isLoading,
    String? error,
    DateTime? lastSyncedAt,
  }) {
    return HealthState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Get all health entries for a specific pet
  List<HealthEntry> getEntriesForPet(String petId) {
    return entries.where((entry) => entry.petId == petId).toList();
  }

  /// Get health entries for a specific pet within a date range
  List<HealthEntry> getEntriesForPetInDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return entries
        .where((entry) =>
            entry.petId == petId &&
            entry.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            entry.timestamp.isBefore(endDate.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get temperature-only entries for a specific pet
  List<HealthEntry> getTemperatureEntries(String petId) {
    return entries
        .where((entry) => entry.petId == petId && entry.temperature != null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get file-based entries (health records) for a specific pet
  List<HealthEntry> getFileEntries(String petId) {
    return entries
        .where((entry) => entry.petId == petId && entry.fileUrl != null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get combined entries (both temperature and file) for a specific pet
  List<HealthEntry> getCombinedEntries(String petId) {
    return entries
        .where((entry) => 
            entry.petId == petId && 
            entry.temperature != null && 
            entry.fileUrl != null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Search health entries by notes content for a specific pet
  List<HealthEntry> searchEntriesByNotes(String petId, String searchTerm) {
    if (searchTerm.isEmpty) {
      return getEntriesForPet(petId);
    }

    return entries
        .where((entry) =>
            entry.petId == petId &&
            entry.notes != null &&
            entry.notes!.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get health entry statistics for a specific pet
  Map<String, dynamic> getHealthEntryStats(String petId) {
    final petEntries = getEntriesForPet(petId);
    
    final totalEntries = petEntries.length;
    final temperatureEntries = petEntries.where((e) => e.temperature != null).length;
    final fileEntries = petEntries.where((e) => e.fileUrl != null).length;
    final combinedEntries = petEntries.where((e) => e.temperature != null && e.fileUrl != null).length;

    // Calculate temperature statistics
    final temperatureValues = petEntries
        .where((e) => e.temperature != null)
        .map((e) => e.temperature!)
        .toList();
    
    double? avgTemperature;
    double? minTemperature;
    double? maxTemperature;
    
    if (temperatureValues.isNotEmpty) {
      avgTemperature = temperatureValues.reduce((a, b) => a + b) / temperatureValues.length;
      minTemperature = temperatureValues.reduce((a, b) => a < b ? a : b);
      maxTemperature = temperatureValues.reduce((a, b) => a > b ? a : b);
    }

    // Get date range
    DateTime? earliestDate;
    DateTime? latestDate;
    
    if (petEntries.isNotEmpty) {
      final dates = petEntries.map((e) => e.timestamp).toList();
      earliestDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
      latestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    }

    return {
      'totalEntries': totalEntries,
      'temperatureEntries': temperatureEntries,
      'fileEntries': fileEntries,
      'combinedEntries': combinedEntries,
      'avgTemperature': avgTemperature,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'earliestDate': earliestDate,
      'latestDate': latestDate,
    };
  }
} 