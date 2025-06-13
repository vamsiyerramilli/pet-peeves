import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food.dart';

@immutable
class FoodTrackingEntry {
  final String id;
  final String petId;
  final DateTime timestamp;
  final String foodId;
  final String foodName;           // denormalized
  final FoodType type;             // denormalized
  final double? kCalPerGram;       // denormalized
  final double weightGrams;
  final double? kCal;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FoodTrackingEntry({
    required this.id,
    required this.petId,
    required this.timestamp,
    required this.foodId,
    required this.foodName,
    required this.type,
    this.kCalPerGram,
    required this.weightGrams,
    this.kCal,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // Create a copy of this entry with the given field values updated
  FoodTrackingEntry copyWith({
    String? id,
    String? petId,
    DateTime? timestamp,
    String? foodId,
    String? foodName,
    FoodType? type,
    double? kCalPerGram,
    double? weightGrams,
    double? kCal,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodTrackingEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      timestamp: timestamp ?? this.timestamp,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      type: type ?? this.type,
      kCalPerGram: kCalPerGram ?? this.kCalPerGram,
      weightGrams: weightGrams ?? this.weightGrams,
      kCal: kCal ?? this.kCal,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert entry to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'timestamp': timestamp.toIso8601String(),
      'foodId': foodId,
      'foodName': foodName,
      'type': type.toString().split('.').last,
      'kCalPerGram': kCalPerGram,
      'weightGrams': weightGrams,
      'kCal': kCal,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create an entry from a Firestore document
  factory FoodTrackingEntry.fromJson(Map<String, dynamic> json) {
    return FoodTrackingEntry(
      id: json['id'] as String,
      petId: json['petId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      foodId: json['foodId'] as String,
      foodName: json['foodName'] as String,
      type: _foodTypeFromString(json['type'] as String),
      kCalPerGram: json['kCalPerGram'] as double?,
      weightGrams: json['weightGrams'] as double,
      kCal: json['kCal'] as double?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  static FoodType _foodTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'dry':
        return FoodType.dry;
      case 'wet':
        return FoodType.wet;
      case 'treat':
        return FoodType.treat;
      default:
        return FoodType.other;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodTrackingEntry &&
        other.id == id &&
        other.petId == petId &&
        other.timestamp == timestamp &&
        other.foodId == foodId &&
        other.foodName == foodName &&
        other.type == type &&
        other.kCalPerGram == kCalPerGram &&
        other.weightGrams == weightGrams &&
        other.kCal == kCal &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      petId,
      timestamp,
      foodId,
      foodName,
      type,
      kCalPerGram,
      weightGrams,
      kCal,
      notes,
      createdAt,
      updatedAt,
    );
  }

  factory FoodTrackingEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodTrackingEntry(
      id: doc.id,
      petId: data['petId'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      foodId: data['foodId'] as String,
      foodName: data['foodName'] as String,
      type: FoodType.values.firstWhere(
        (t) => t.toString() == data['type'] as String,
        orElse: () => FoodType.dry,
      ),
      kCalPerGram: (data['kCalPerGram'] as num?)?.toDouble(),
      weightGrams: (data['weightGrams'] as num).toDouble(),
      kCal: (data['kCal'] as num?)?.toDouble(),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'timestamp': Timestamp.fromDate(timestamp),
      'foodId': foodId,
      'foodName': foodName,
      'type': type.toString(),
      'kCalPerGram': kCalPerGram,
      'weightGrams': weightGrams,
      'kCal': kCal,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
} 