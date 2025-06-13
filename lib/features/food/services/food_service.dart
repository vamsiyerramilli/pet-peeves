import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food.dart';
import '../models/food_tracking_entry.dart';

class FoodService {
  final FirebaseFirestore _firestore;

  FoodService(this._firestore);

  // Food CRUD operations
  Future<List<Food>> getFoods(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('foods')
        .get();
    return snapshot.docs.map((doc) => Food.fromFirestore(doc)).toList();
  }

  Future<Food> addFood(String userId, Food food) async {
    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('foods')
        .add(food.toFirestore());
    return food.copyWith(id: docRef.id);
  }

  Future<Food> updateFood(String userId, Food food) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('foods')
        .doc(food.id)
        .update(food.toFirestore());
    return food;
  }

  Future<void> deleteFood(String userId, String foodId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('foods')
        .doc(foodId)
        .delete();
  }

  // Food Tracking Entry CRUD operations
  Future<List<FoodTrackingEntry>> getFoodTrackingEntries(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .collection('food_entries')
        .orderBy('timestamp', descending: true);

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => FoodTrackingEntry.fromFirestore(doc)).toList();
  }

  Future<FoodTrackingEntry> addFoodTrackingEntry(String userId, FoodTrackingEntry entry) async {
    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(entry.petId)
        .collection('food_entries')
        .add(entry.toFirestore());
    return entry.copyWith(id: docRef.id);
  }

  Future<FoodTrackingEntry> updateFoodTrackingEntry(String userId, FoodTrackingEntry entry) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(entry.petId)
        .collection('food_entries')
        .doc(entry.id)
        .update(entry.toFirestore());
    return entry;
  }

  Future<void> deleteFoodTrackingEntry(String userId, String petId, String entryId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .collection('food_entries')
        .doc(entryId)
        .delete();
  }
} 