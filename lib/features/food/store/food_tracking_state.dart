import 'package:flutter/foundation.dart';
import '../models/food_tracking_entry.dart';

@immutable
class FoodTrackingState {
  final Map<String, List<FoodTrackingEntry>> entriesByPet;
  final bool isLoading;
  final String? error;
  // Map of petId -> (entryId -> isPending)
  final Map<String, Map<String, bool>> pendingSyncByPetId;

  const FoodTrackingState({
    required this.entriesByPet,
    required this.isLoading,
    this.error,
    this.pendingSyncByPetId = const {},
  });

  factory FoodTrackingState.initial() {
    return const FoodTrackingState(
      entriesByPet: {},
      isLoading: false,
      pendingSyncByPetId: {},
    );
  }

  FoodTrackingState copyWith({
    Map<String, List<FoodTrackingEntry>>? entriesByPet,
    bool? isLoading,
    String? error,
    Map<String, Map<String, bool>>? pendingSyncByPetId,
  }) {
    return FoodTrackingState(
      entriesByPet: entriesByPet ?? this.entriesByPet,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pendingSyncByPetId: pendingSyncByPetId ?? this.pendingSyncByPetId,
    );
  }

  List<FoodTrackingEntry> getEntriesForPet(String petId) {
    return entriesByPet[petId] ?? [];
  }

  Map<DateTime, List<FoodTrackingEntry>> getEntriesGroupedByDate(String petId) {
    final entries = getEntriesForPet(petId);
    final groupedEntries = <DateTime, List<FoodTrackingEntry>>{};

    for (final entry in entries) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      if (!groupedEntries.containsKey(date)) {
        groupedEntries[date] = [];
      }
      groupedEntries[date]!.add(entry);
    }

    return Map.fromEntries(
      groupedEntries.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  /// Add or replace an entry for a pet
  FoodTrackingState addEntry(String petId, FoodTrackingEntry entry) {
    final updatedEntries = List<FoodTrackingEntry>.from(entriesByPet[petId] ?? [])
      ..removeWhere((e) => e.id == entry.id)
      ..add(entry);

    final newMap = Map<String, List<FoodTrackingEntry>>.from(entriesByPet)
      ..[petId] = updatedEntries;

    return copyWith(entriesByPet: newMap);
  }

  /// Update an existing entry (alias of addEntry for convenience)
  FoodTrackingState updateEntry(String petId, FoodTrackingEntry entry) =>
      addEntry(petId, entry);

  /// Delete an entry
  FoodTrackingState deleteEntry(String petId, String entryId) {
    if (!entriesByPet.containsKey(petId)) return this;

    final updatedEntries = List<FoodTrackingEntry>.from(entriesByPet[petId]!)
      ..removeWhere((e) => e.id == entryId);

    final newMap = Map<String, List<FoodTrackingEntry>>.from(entriesByPet)
      ..[petId] = updatedEntries;

    return copyWith(entriesByPet: newMap);
  }

  /// Returns whether the given entry is pending sync.
  bool isEntryPending(String petId, String entryId) {
    return pendingSyncByPetId[petId]?[entryId] ?? false;
  }

  /// Update sync status for an entry (returns new state).
  FoodTrackingState setEntrySyncStatus(String petId, String entryId, bool isPending) {
    final petMap = Map<String, bool>.from(pendingSyncByPetId[petId] ?? {})
      ..[entryId] = isPending;
    final newMap = Map<String, Map<String, bool>>.from(pendingSyncByPetId)
      ..[petId] = petMap;
    return copyWith(pendingSyncByPetId: newMap);
  }

  // Equality & hashing
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodTrackingState &&
        mapEquals(other.entriesByPet, entriesByPet) &&
        other.isLoading == isLoading &&
        other.error == error &&
        mapEquals(other.pendingSyncByPetId, pendingSyncByPetId);
  }

  @override
  int get hashCode => Object.hash(entriesByPet.hashCode, isLoading, error, pendingSyncByPetId.hashCode);
} 