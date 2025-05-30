import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_peeves/models/pet.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new pet
  Future<String> addPet(Pet pet) async {
    final docRef = await _firestore.collection('pets').add(pet.toMap());
    return docRef.id;
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