import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/pet_model.dart';
import '../models/measurement_model.dart';
import '../models/health_log_model.dart';

class PetOnboardingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create a new pet with basic details
  Future<PetModel> createPet({
    required String userId,
    required String name,
    required Species species,
    String? otherSpecies,
    required Gender gender,
    DateTime? dateOfBirth,
    DateTime? adoptionDate,
    File? profilePhoto,
  }) async {
    try {
      // Upload profile photo if provided
      String? profilePhotoUrl;
      if (profilePhoto != null) {
        final ref = _storage.ref()
            .child('users/$userId/pets')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        await ref.putFile(profilePhoto);
        profilePhotoUrl = await ref.getDownloadURL();
      }

      // Create pet document
      final now = DateTime.now();
      final petRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc();

      final pet = PetModel(
        id: petRef.id,
        name: name,
        profilePhotoUrl: profilePhotoUrl,
        species: species,
        otherSpecies: otherSpecies,
        gender: gender,
        dateOfBirth: dateOfBirth,
        adoptionDate: adoptionDate,
        createdAt: now,
        updatedAt: now,
      );

      await petRef.set(pet.toMap());
      return pet;
    } catch (e) {
      rethrow;
    }
  }

  // Add initial measurements
  Future<MeasurementModel> addInitialMeasurements({
    required String userId,
    required String petId,
    double? weight,
    double? length,
    double? height,
    String? notes,
  }) async {
    try {
      final measurementRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('measurements')
          .doc();

      final measurement = MeasurementModel(
        id: measurementRef.id,
        petId: petId,
        weight: weight,
        length: length,
        height: height,
        notes: notes,
        timestamp: DateTime.now(),
      );

      await measurementRef.set(measurement.toMap());
      return measurement;
    } catch (e) {
      rethrow;
    }
  }

  // Add initial health log
  Future<HealthLogModel> addInitialHealthLog({
    required String userId,
    required String petId,
    VaccinationStatus? vaccinationStatus,
    String? notes,
  }) async {
    try {
      final healthLogRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('health_logs')
          .doc();

      final healthLog = HealthLogModel(
        id: healthLogRef.id,
        petId: petId,
        type: HealthLogType.vaccination,
        vaccinationStatus: vaccinationStatus,
        notes: notes,
        timestamp: DateTime.now(),
      );

      await healthLogRef.set(healthLog.toMap());
      return healthLog;
    } catch (e) {
      rethrow;
    }
  }

  // Check if pet name is duplicate
  Future<bool> isPetNameDuplicate({
    required String userId,
    required String name,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .where('name', isEqualTo: name)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  // Delete pet and all associated data
  Future<void> deletePet({
    required String userId,
    required String petId,
  }) async {
    try {
      // Delete pet document and all subcollections
      final petRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId);

      // Delete measurements
      final measurements = await petRef.collection('measurements').get();
      for (var doc in measurements.docs) {
        await doc.reference.delete();
      }

      // Delete health logs
      final healthLogs = await petRef.collection('health_logs').get();
      for (var doc in healthLogs.docs) {
        await doc.reference.delete();
      }

      // Delete pet document
      await petRef.delete();
    } catch (e) {
      rethrow;
    }
  }
} 