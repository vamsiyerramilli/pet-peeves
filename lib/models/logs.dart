import 'package:cloud_firestore/cloud_firestore.dart';

enum LogType {
  food,
  health,
  vaccine,
  measurement,
}

class BaseLog {
  final String? id;
  final String petId;
  final DateTime timestamp;
  final String notes;
  final LogType type;

  const BaseLog({
    this.id,
    required this.petId,
    required this.timestamp,
    required this.notes,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'type': type.toString(),
    };
  }
}

class FoodLog extends BaseLog {
  final String foodName;
  final double amount;
  final String unit;
  final double? energyContent;

  const FoodLog({
    required super.id,
    required super.petId,
    required super.timestamp,
    required super.notes,
    required this.foodName,
    required this.amount,
    required this.unit,
    this.energyContent,
  }) : super(type: LogType.food);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'foodName': foodName,
      'amount': amount,
      'unit': unit,
      'energyContent': energyContent,
    };
  }

  factory FoodLog.fromMap(String id, Map<String, dynamic> map) {
    return FoodLog(
      id: id,
      petId: map['petId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      notes: map['notes'] as String,
      foodName: map['foodName'] as String,
      amount: map['amount'] as double,
      unit: map['unit'] as String,
      energyContent: map['energyContent'] as double?,
    );
  }
}

class HealthLog extends BaseLog {
  final String condition;
  final String severity;
  final List<String> symptoms;
  final String? diagnosis;
  final String? treatment;
  final DateTime? nextDueDate;

  const HealthLog({
    required super.id,
    required super.petId,
    required super.timestamp,
    required super.notes,
    required this.condition,
    required this.severity,
    required this.symptoms,
    this.diagnosis,
    this.treatment,
    this.nextDueDate,
  }) : super(type: LogType.health);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'condition': condition,
      'severity': severity,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'nextDueDate': nextDueDate != null ? Timestamp.fromDate(nextDueDate!) : null,
    };
  }

  factory HealthLog.fromMap(String id, Map<String, dynamic> map) {
    return HealthLog(
      id: id,
      petId: map['petId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      notes: map['notes'] as String,
      condition: map['condition'] as String,
      severity: map['severity'] as String,
      symptoms: List<String>.from(map['symptoms'] as List),
      diagnosis: map['diagnosis'] as String?,
      treatment: map['treatment'] as String?,
      nextDueDate: (map['nextDueDate'] as Timestamp?)?.toDate(),
    );
  }
}

class VaccineLog extends BaseLog {
  final String vaccineName;
  final String administeredBy;
  final DateTime nextDueDate;
  final String? batchNumber;

  const VaccineLog({
    required super.id,
    required super.petId,
    required super.timestamp,
    required super.notes,
    required this.vaccineName,
    required this.administeredBy,
    required this.nextDueDate,
    this.batchNumber,
  }) : super(type: LogType.vaccine);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'vaccineName': vaccineName,
      'administeredBy': administeredBy,
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'batchNumber': batchNumber,
    };
  }

  factory VaccineLog.fromMap(String id, Map<String, dynamic> map) {
    return VaccineLog(
      id: id,
      petId: map['petId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      notes: map['notes'] as String,
      vaccineName: map['vaccineName'] as String,
      administeredBy: map['administeredBy'] as String,
      nextDueDate: (map['nextDueDate'] as Timestamp).toDate(),
      batchNumber: map['batchNumber'] as String?,
    );
  }
}

class MeasurementLog extends BaseLog {
  final double weight;
  final double height;
  final double length;

  const MeasurementLog({
    required super.id,
    required super.petId,
    required super.timestamp,
    required super.notes,
    required this.weight,
    required this.height,
    required this.length,
  }) : super(type: LogType.measurement);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'weight': weight,
      'height': height,
      'length': length,
    };
  }

  factory MeasurementLog.fromMap(String id, Map<String, dynamic> map) {
    return MeasurementLog(
      id: id,
      petId: map['petId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      notes: map['notes'] as String,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      length: (map['length'] as num).toDouble(),
    );
  }
} 