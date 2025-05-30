import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_peeves/models/pet.dart';
import 'dart:developer' as developer;

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
} 