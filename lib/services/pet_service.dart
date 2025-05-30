import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_peeves/models/pet.dart';
import 'dart:developer' as developer;
import 'package:pet_peeves/models/logs.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new pet
  Future<String> addPet(Pet pet) async {
    try {
      developer.log('Attempting to save pet: ${pet.name}');
      final petMap = pet.toMap();
      developer.log('Pet data to save: $petMap');
      
      final docRef = await _firestore.collection('pets').add(petMap);
      developer.log('Pet saved successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      developer.log(
        'Error saving pet: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;  // Re-throw the error so it can be caught by the UI
    }
  }

  // Get all pets for a user
  Stream<List<Pet>> getPetsForUser(String userId) {
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Pet.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Get food logs for a pet
  Stream<List<FoodLog>> getFoodLogs(String? petId) {
    if (petId == null) {
      return Stream.value([]); // Return an empty stream if petId is null
    }
    return _firestore
        .collection('pets')
        .doc(petId)
        .collection('food') // Assuming food logs are in a 'food' subcollection
        .orderBy('timestamp', descending: true) // Assuming a timestamp field
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodLog.fromMap(doc.id, doc.data())) // Assuming FoodLog.fromMap exists
          .toList();
    });
  }

  // Get health logs for a pet
  Stream<List<HealthLog>> getHealthLogs(String? petId) {
    if (petId == null) {
      return Stream.value([]); // Return an empty stream if petId is null
    }
    return _firestore
        .collection('pets')
        .doc(petId)
        .collection('healthLogs') // Assuming health logs are in a 'healthLogs' subcollection
        .orderBy('timestamp', descending: true) // Assuming a timestamp field
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => HealthLog.fromMap(doc.id, doc.data())) // Assuming HealthLog.fromMap exists
          .toList();
    });
  }

  // Get measurement logs for a pet
  Stream<List<MeasurementLog>> getMeasurementLogs(String? petId) {
    if (petId == null) {
      return Stream.value([]); // Return an empty stream if petId is null
    }
    return _firestore
        .collection('pets')
        .doc(petId)
        .collection('measurements') // Assuming measurement logs are in a 'measurements' subcollection
        .orderBy('timestamp', descending: true) // Assuming a timestamp field
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MeasurementLog.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Update a pet
  Future<void> updatePet(Pet pet) async {
    if (pet.id == null) throw Exception('Pet ID is required for update');
    await _firestore.collection('pets').doc(pet.id).update(pet.toMap());
  }

  // Delete a pet
  Future<void> deletePet(String petId) async {
    await _firestore.collection('pets').doc(petId).delete();
  }

  // Update user's hasPets status
  Future<void> updateUserHasPets(String userId, bool hasPets) async {
    await _firestore.collection('users').doc(userId).update({
      'hasPets': hasPets,
    });
  }

  // Fetch all pets for a user as a Future (one-time fetch)
  Future<List<Pet>> fetchPetsForUser(String userId) async {
    final snapshot = await _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => Pet.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Add a new food log for a pet
  Future<void> addFoodLog({
    required String petId,
    required String foodName,
    required double amount,
    required double energyPerGram,
    String? notes,
    String unit = 'g', // Default to grams if not specified
    required DateTime timestamp,
  }) async {
    final foodLog = FoodLog(
      id: null, // Firestore will generate the ID
      petId: petId,
      timestamp: timestamp,
      notes: notes ?? '',
      foodName: foodName,
      amount: amount,
      unit: unit,
      energyContent: energyPerGram,
    );

    try {
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('food') // Save to the 'food' subcollection
          .add(foodLog.toMap());
      developer.log('Food log added successfully for pet: $petId');
    } catch (e, stackTrace) {
      developer.log(
        'Error adding food log for pet: $petId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow; // Re-throw the error for handling in the UI
    }
  }

  // Add a new measurement log for a pet
  Future<void> addMeasurementLog({
    required String petId,
    required double weight,
    required double height,
    required double length,
    String? notes,
    required DateTime timestamp,
  }) async {
    final measurementLog = MeasurementLog(
      id: null, // Firestore will generate the ID
      petId: petId,
      timestamp: timestamp,
      notes: notes ?? '',
      weight: weight,
      height: height,
      length: length,
    );

    try {
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('measurements')
          .add(measurementLog.toMap());
      developer.log('Measurement log added successfully for pet: $petId');
    } catch (e, stackTrace) {
      developer.log(
        'Error adding measurement log for pet: $petId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow; // Re-throw the error for handling in the UI
    }
  }

  // Add a new health log for a pet
  Future<void> addHealthLog({
    required String petId,
    required String type,
    required String notes,
    DateTime? nextDueDate,
    required DateTime timestamp,
  }) async {
    final healthLog = HealthLog(
      id: null, // Firestore will generate the ID
      petId: petId,
      timestamp: timestamp,
      notes: notes,
      condition: type,
      severity: 'Normal', // Default severity
      symptoms: [], // Default empty symptoms list
      diagnosis: null,
      treatment: null,
      nextDueDate: nextDueDate,
    );

    try {
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .add(healthLog.toMap());
      developer.log('Health log added successfully for pet: $petId');
    } catch (e, stackTrace) {
      developer.log(
        'Error adding health log for pet: $petId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow; // Re-throw the error for handling in the UI
    }
  }
} 