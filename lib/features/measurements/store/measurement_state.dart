import 'package:flutter/foundation.dart';
import '../models/measurement_entry.dart';
import 'measurement_actions.dart';

@immutable
class MeasurementState {
  final List<MeasurementEntry> entries;
  final bool isLoading;
  final String? error;
  final DateTime? lastSyncedAt;

  const MeasurementState({
    required this.entries,
    required this.isLoading,
    this.error,
    this.lastSyncedAt,
  });

  factory MeasurementState.initial() {
    return MeasurementState(
      entries: [],
      isLoading: false,
      error: null,
      lastSyncedAt: null,
    );
  }

  // Get entries for a specific pet, sorted by timestamp (newest first)
  List<MeasurementEntry> getEntriesForPet(String petId) {
    return entries
        .where((entry) => entry.petId == petId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get entries for a specific pet within a date range
  List<MeasurementEntry> getEntriesForPetInDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return entries
        .where((entry) =>
            entry.petId == petId &&
            entry.timestamp.isAfter(startDate) &&
            entry.timestamp.isBefore(endDate))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Helper methods for filtering entries by type
  List<MeasurementEntry> getWeightEntries(String petId) {
    return entries
        .where((e) => e.petId == petId && e.weightKg != null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<MeasurementEntry> getHeightEntries(String petId) {
    return entries
        .where((e) => e.petId == petId && e.heightCm != null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<MeasurementEntry> getLengthEntries(String petId) {
    return entries
        .where((e) => e.petId == petId && e.lengthCm != null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get latest measurements for a pet
  MeasurementEntry? getLatestWeightEntry(String petId) {
    final weightEntries = getWeightEntries(petId);
    return weightEntries.isNotEmpty ? weightEntries.first : null;
  }

  MeasurementEntry? getLatestHeightEntry(String petId) {
    final heightEntries = getHeightEntries(petId);
    return heightEntries.isNotEmpty ? heightEntries.first : null;
  }

  MeasurementEntry? getLatestLengthEntry(String petId) {
    final lengthEntries = getLengthEntries(petId);
    return lengthEntries.isNotEmpty ? lengthEntries.first : null;
  }

  // Validation helper methods
  static bool isValidWeight(double? weight) {
    if (weight == null) return true;
    return weight > 0 && weight <= 1000;
  }

  static bool isValidHeight(double? height) {
    if (height == null) return true;
    return height > 0 && height <= 10000;
  }

  static bool isValidLength(double? length) {
    if (length == null) return true;
    return length > 0 && length <= 10000;
  }

  static bool hasAtLeastOneMeasurement(
    double? weight,
    double? height,
    double? length,
  ) {
    return weight != null || height != null || length != null;
  }

  MeasurementState copyWith({
    List<MeasurementEntry>? entries,
    bool? isLoading,
    String? error,
    DateTime? lastSyncedAt,
  }) {
    return MeasurementState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MeasurementState &&
        listEquals(other.entries, entries) &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.lastSyncedAt == lastSyncedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(entries),
      isLoading,
      error,
      lastSyncedAt,
    );
  }
} 