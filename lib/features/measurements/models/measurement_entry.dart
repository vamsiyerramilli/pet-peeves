import 'package:cloud_firestore/cloud_firestore.dart';

class MeasurementEntry {
  final String id;
  final String petId;
  final DateTime timestamp;
  final double? weightKg;    // Optional, float, 0.01–1000
  final double? heightCm;    // Optional, float, 1–10000
  final double? lengthCm;    // Optional, float, 1–10000
  final String? notes;       // Optional, free text
  final String? createdBy;   // For future multi-user support
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<MeasurementAudit>? auditTrail;  // For tracking changes

  MeasurementEntry({
    required this.id,
    required this.petId,
    required this.timestamp,
    this.weightKg,
    this.heightCm,
    this.lengthCm,
    this.notes,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.auditTrail,
  });

  MeasurementEntry copyWith({
    String? id,
    String? petId,
    DateTime? timestamp,
    double? weightKg,
    double? heightCm,
    double? lengthCm,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MeasurementAudit>? auditTrail,
  }) {
    return MeasurementEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      timestamp: timestamp ?? this.timestamp,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      lengthCm: lengthCm ?? this.lengthCm,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      auditTrail: auditTrail ?? this.auditTrail,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'petId': petId,
      'timestamp': Timestamp.fromDate(timestamp),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'lengthCm': lengthCm,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'auditTrail': auditTrail?.map((audit) => audit.toFirestore()).toList(),
    };
  }

  factory MeasurementEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MeasurementEntry(
      id: data['id'] as String,
      petId: data['petId'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      weightKg: data['weightKg'] as double?,
      heightCm: data['heightCm'] as double?,
      lengthCm: data['lengthCm'] as double?,
      notes: data['notes'] as String?,
      createdBy: data['createdBy'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      auditTrail: data['auditTrail'] != null
          ? (data['auditTrail'] as List)
              .map((audit) => MeasurementAudit.fromFirestore(audit))
              .toList()
          : null,
    );
  }

  void validate() {
    if (weightKg == null && heightCm == null && lengthCm == null) {
      throw Exception('At least one measurement (weight, height, or length) is required');
    }

    if (weightKg != null) {
      if (weightKg! <= 0 || weightKg! > 1000) {
        throw Exception('Weight must be between 0.01 and 1000 kg');
      }
    }

    if (heightCm != null) {
      if (heightCm! <= 0 || heightCm! > 10000) {
        throw Exception('Height must be between 1 and 10000 cm');
      }
    }

    if (lengthCm != null) {
      if (lengthCm! <= 0 || lengthCm! > 10000) {
        throw Exception('Length must be between 1 and 10000 cm');
      }
    }
  }

  MeasurementEntry addAuditEntry(String updatedBy, Map<String, dynamic> oldValues) {
    final audit = MeasurementAudit(
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
      oldValues: oldValues,
    );

    final updatedAuditTrail = [...?auditTrail, audit];
    return copyWith(auditTrail: updatedAuditTrail);
  }
}

class MeasurementAudit {
  final DateTime updatedAt;
  final String updatedBy;
  final Map<String, dynamic> oldValues;

  MeasurementAudit({
    required this.updatedAt,
    required this.updatedBy,
    required this.oldValues,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
      'oldValues': oldValues,
    };
  }

  factory MeasurementAudit.fromFirestore(Map<String, dynamic> data) {
    return MeasurementAudit(
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      updatedBy: data['updatedBy'] as String,
      oldValues: data['oldValues'] as Map<String, dynamic>,
    );
  }

  factory MeasurementAudit.fromJson(Map<String, dynamic> json) {
    return MeasurementAudit(
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
      oldValues: json['oldValues'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
      'oldValues': oldValues,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
      'oldValues': oldValues,
    };
  }
} 