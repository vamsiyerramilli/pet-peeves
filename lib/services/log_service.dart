import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_peeves/models/logs.dart';

class LogService {
  final FirebaseFirestore _firestore;
  static const int _pageSize = 20;

  LogService(this._firestore);

  CollectionReference _getLogCollection(String petId, LogType type) {
    final subcollection = switch (type) {
      LogType.food => 'foodLogs',
      LogType.health => 'healthLogs',
      LogType.vaccine => 'vaccineLogs',
    };
    return _firestore
        .collection('pets')
        .doc(petId)
        .collection(subcollection);
  }

  Future<String> addFoodLog(FoodLog log) async {
    final docRef = await _getLogCollection(log.petId, LogType.food).add(log.toMap());
    return docRef.id;
  }

  Future<String> addHealthLog(HealthLog log) async {
    final docRef = await _getLogCollection(log.petId, LogType.health).add(log.toMap());
    return docRef.id;
  }

  Future<String> addVaccineLog(VaccineLog log) async {
    final docRef = await _getLogCollection(log.petId, LogType.vaccine).add(log.toMap());
    return docRef.id;
  }

  Stream<List<BaseLog>> getLogs(
    String petId, {
    LogType? type,
    DocumentSnapshot? lastDocument,
  }) {
    final query = type != null
        ? _getLogCollection(petId, type)
        : _firestore.collection('pets').doc(petId).collection('allLogs');

    var paginatedQuery = query
        .orderBy('timestamp', descending: true)
        .limit(_pageSize);

    if (lastDocument != null) {
      paginatedQuery = paginatedQuery.startAfterDocument(lastDocument);
    }

    return paginatedQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return switch (data['type'] as String) {
          'LogType.food' => FoodLog.fromMap(doc.id, data),
          'LogType.health' => HealthLog.fromMap(doc.id, data),
          'LogType.vaccine' => VaccineLog.fromMap(doc.id, data),
          _ => throw Exception('Unknown log type'),
        };
      }).toList();
    });
  }

  Future<void> deleteLog(String petId, String logId, LogType type) async {
    await _getLogCollection(petId, type).doc(logId).delete();
  }

  Future<void> updateFoodLog(FoodLog log) async {
    await _getLogCollection(log.petId, LogType.food)
        .doc(log.id)
        .update(log.toMap());
  }

  Future<void> updateHealthLog(HealthLog log) async {
    await _getLogCollection(log.petId, LogType.health)
        .doc(log.id)
        .update(log.toMap());
  }

  Future<void> updateVaccineLog(VaccineLog log) async {
    await _getLogCollection(log.petId, LogType.vaccine)
        .doc(log.id)
        .update(log.toMap());
  }
} 