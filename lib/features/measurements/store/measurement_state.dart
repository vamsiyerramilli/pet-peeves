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

  // Helper methods for filtering entries
  List<MeasurementEntry> getWeightEntries() {
    return entries
        .where((e) => e.weightKg != null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<MeasurementEntry> getHeightEntries() {
    return entries
        .where((e) => e.heightCm != null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<MeasurementEntry> getLengthEntries() {
    return entries
        .where((e) => e.lengthCm != null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get latest measurements
  MeasurementEntry? getLatestWeightEntry() {
    final weightEntries = getWeightEntries();
    return weightEntries.isNotEmpty ? weightEntries.first : null;
  }

  MeasurementEntry? getLatestHeightEntry() {
    final heightEntries = getHeightEntries();
    return heightEntries.isNotEmpty ? heightEntries.first : null;
  }

  MeasurementEntry? getLatestLengthEntry() {
    final lengthEntries = getLengthEntries();
    return lengthEntries.isNotEmpty ? lengthEntries.first : null;
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