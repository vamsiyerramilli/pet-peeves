import 'package:cloud_firestore/cloud_firestore.dart';

enum VaccinationStatus { notVaccinated, partiallyVaccinated, fullyVaccinated }
enum HealthLogType { vaccination }

class HealthLogModel {
  final String id;
  final String petId;
  final HealthLogType type;
  final VaccinationStatus? vaccinationStatus;
  final String? notes;
  final DateTime timestamp;

  HealthLogModel({
    required this.id,
    required this.petId,
    required this.type,
    this.vaccinationStatus,
    this.notes,
    required this.timestamp,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'type': type.toString().split('.').last,
      'vaccinationStatus': vaccinationStatus?.toString().split('.').last,
      'notes': notes,
      'timestamp': timestamp,
    };
  }

  // Create from Firestore document
  factory HealthLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthLogModel(
      id: doc.id,
      petId: data['petId'] as String,
      type: HealthLogType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => HealthLogType.vaccination,
      ),
      vaccinationStatus: data['vaccinationStatus'] != null
          ? VaccinationStatus.values.firstWhere(
              (e) => e.toString().split('.').last == data['vaccinationStatus'],
              orElse: () => VaccinationStatus.notVaccinated,
            )
          : null,
      notes: data['notes'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Create a copy with updated fields
  HealthLogModel copyWith({
    VaccinationStatus? vaccinationStatus,
    String? notes,
  }) {
    return HealthLogModel(
      id: id,
      petId: petId,
      type: type,
      vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
      notes: notes ?? this.notes,
      timestamp: timestamp,
    );
  }
} 