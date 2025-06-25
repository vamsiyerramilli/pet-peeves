import 'package:cloud_firestore/cloud_firestore.dart';

class HealthEntry {
  final String id;
  final String petId;
  final DateTime timestamp;
  final String? fileUrl;
  final double? temperature;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<HealthAudit>? auditTrail;

  HealthEntry({
    required this.id,
    required this.petId,
    required this.timestamp,
    this.fileUrl,
    this.temperature,
    this.notes,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.auditTrail,
  });

  HealthEntry copyWith({
    String? id,
    String? petId,
    DateTime? timestamp,
    String? fileUrl,
    double? temperature,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<HealthAudit>? auditTrail,
  }) {
    return HealthEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      timestamp: timestamp ?? this.timestamp,
      fileUrl: fileUrl ?? this.fileUrl,
      temperature: temperature ?? this.temperature,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      auditTrail: auditTrail ?? this.auditTrail,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'fileUrl': fileUrl,
      'temperature': temperature,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'auditTrail': auditTrail?.map((audit) => audit.toFirestore()).toList(),
    };
  }

  factory HealthEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthEntry(
      id: doc.id,
      petId: '', // petId is now part of the collection path, not stored in document
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      fileUrl: data['fileUrl'] as String?,
      temperature: data['temperature'] != null ? (data['temperature'] as num).toDouble() : null,
      notes: data['notes'] as String?,
      createdBy: data['createdBy'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      auditTrail: data['auditTrail'] != null
          ? (data['auditTrail'] as List)
              .map((audit) => HealthAudit.fromFirestore(audit))
              .toList()
          : null,
    );
  }

  factory HealthEntry.fromJson(Map<String, dynamic> json) {
    return HealthEntry(
      id: json['id'] as String,
      petId: json['petId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      fileUrl: json['fileUrl'] as String?,
      temperature: (json['temperature'] != null) ? (json['temperature'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      auditTrail: json['auditTrail'] != null
          ? (json['auditTrail'] as List)
              .map((e) => HealthAudit.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'timestamp': timestamp.toIso8601String(),
        'fileUrl': fileUrl,
        'temperature': temperature,
        'notes': notes,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'auditTrail': auditTrail?.map((e) => e.toJson()).toList(),
      };
}

class HealthAudit {
  final DateTime updatedAt;
  final String updatedBy;
  final Map<String, dynamic> oldValues;

  HealthAudit({
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

  factory HealthAudit.fromFirestore(Map<String, dynamic> data) {
    return HealthAudit(
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      updatedBy: data['updatedBy'] as String,
      oldValues: data['oldValues'] as Map<String, dynamic>,
    );
  }

  factory HealthAudit.fromJson(Map<String, dynamic> json) {
    return HealthAudit(
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
      oldValues: Map<String, dynamic>.from(json['oldValues'] as Map),
    );
  }

  Map<String, dynamic> toJson() => {
        'updatedAt': updatedAt.toIso8601String(),
        'updatedBy': updatedBy,
        'oldValues': oldValues,
      };
} 