import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/measurement_entry.dart';

class MeasurementService {
  final FirebaseFirestore _firestore;

  MeasurementService(this._firestore);

  Future<List<MeasurementEntry>> loadMeasurements(String petId) async {
    try {
      final snapshot = await _firestore
          .collection('measurements')
          .where('petId', isEqualTo: petId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MeasurementEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load measurements: ${e.toString()}');
    }
  }

  Future<MeasurementEntry> addMeasurement(String petId, MeasurementEntry entry) async {
    try {
      _validateMeasurement(entry);

      final docRef = _firestore.collection('measurements').doc();
      final newEntry = entry.copyWith(
        id: docRef.id,
        petId: petId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(newEntry.toFirestore());
      return newEntry;
    } catch (e) {
      throw Exception('Failed to add measurement: ${e.toString()}');
    }
  }

  Future<MeasurementEntry> editMeasurement(String petId, MeasurementEntry entry) async {
    try {
      _validateMeasurement(entry);

      final updatedEntry = entry.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('measurements')
          .doc(entry.id)
          .update(updatedEntry.toFirestore());

      return updatedEntry;
    } catch (e) {
      throw Exception('Failed to edit measurement: ${e.toString()}');
    }
  }

  Future<void> deleteMeasurement(String petId, String entryId) async {
    try {
      await _firestore
          .collection('measurements')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete measurement: ${e.toString()}');
    }
  }

  void _validateMeasurement(MeasurementEntry entry) {
    if (entry.weightKg == null && entry.heightCm == null && entry.lengthCm == null) {
      throw Exception('At least one measurement (weight, height, or length) is required');
    }

    if (entry.weightKg != null) {
      if (entry.weightKg! <= 0 || entry.weightKg! > 1000) {
        throw Exception('Weight must be between 0.01 and 1000 kg');
      }
    }

    if (entry.heightCm != null) {
      if (entry.heightCm! <= 0 || entry.heightCm! > 10000) {
        throw Exception('Height must be between 1 and 10000 cm');
      }
    }

    if (entry.lengthCm != null) {
      if (entry.lengthCm! <= 0 || entry.lengthCm! > 10000) {
        throw Exception('Length must be between 1 and 10000 cm');
      }
    }
  }
} 