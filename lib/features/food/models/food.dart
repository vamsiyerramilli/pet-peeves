import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum FoodType { dry, wet, treat, other }

@immutable
class Food {
  final String id;
  final String name;
  final FoodType type;
  final double? kCalPerGram;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;

  const Food({
    required this.id,
    required this.name,
    required this.type,
    this.kCalPerGram,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
  });

  // Create a copy of this Food with the given field values updated
  Food copyWith({
    String? id,
    String? name,
    FoodType? type,
    double? kCalPerGram,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      kCalPerGram: kCalPerGram ?? this.kCalPerGram,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert Food to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'kCalPerGram': kCalPerGram,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a Food from a Firestore document
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _foodTypeFromString(json['type'] as String),
      kCalPerGram: json['kCalPerGram'] as double?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String?,
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
    return other is Food &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.kCalPerGram == kCalPerGram &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      type,
      kCalPerGram,
      createdAt,
      createdBy,
      updatedAt,
    );
  }

  factory Food.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Food(
      id: doc.id,
      name: data['name'] as String,
      type: FoodType.values.firstWhere(
        (t) => t.toString() == data['type'] as String,
        orElse: () => FoodType.dry,
      ),
      kCalPerGram: (data['kCalPerGram'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.toString(),
      'kCalPerGram': kCalPerGram,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 