import 'package:cloud_firestore/cloud_firestore.dart';

class MeasurementModel {
  final String id;
  final String petId;
  final double? weight; // in kg
  final double? length; // in cm
  final double? height; // in cm
  final String? notes;
  final DateTime timestamp;

  MeasurementModel({
    required this.id,
    required this.petId,
    this.weight,
    this.length,
    this.height,
    this.notes,
    required this.timestamp,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'weight': weight,
      'length': length,
      'height': height,
      'notes': notes,
      'timestamp': timestamp,
    };
  }

  // Create from Firestore document
  factory MeasurementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MeasurementModel(
      id: doc.id,
      petId: data['petId'] as String,
      weight: (data['weight'] as num?)?.toDouble(),
      length: (data['length'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      notes: data['notes'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Create a copy with updated fields
  MeasurementModel copyWith({
    double? weight,
    double? length,
    double? height,
    String? notes,
  }) {
    return MeasurementModel(
      id: id,
      petId: petId,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      height: height ?? this.height,
      notes: notes ?? this.notes,
      timestamp: timestamp,
    );
  }
} 