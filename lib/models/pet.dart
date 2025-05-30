import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String? id;
  final String name;
  final String species;
  final DateTime? dateOfBirth;
  final String gender;
  final DateTime? adoptionDate;
  final String? photoURL;
  final PetMeasurements? measurements;
  final List<PetFood>? foods;
  final List<PetVaccination>? vaccinations;
  final String ownerId;
  final DateTime createdAt;

  Pet({
    this.id,
    required this.name,
    required this.species,
    this.dateOfBirth,
    required this.gender,
    this.adoptionDate,
    this.photoURL,
    this.measurements,
    this.foods,
    this.vaccinations,
    required this.ownerId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'species': species,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'adoptionDate': adoptionDate,
      'photoURL': photoURL,
      'measurements': measurements?.toMap(),
      'foods': foods?.map((f) => f.toMap()).toList(),
      'vaccinations': vaccinations?.map((v) => v.toMap()).toList(),
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Pet.fromMap(String id, Map<String, dynamic> map) {
    return Pet(
      id: id,
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: map['gender'] ?? '',
      adoptionDate: (map['adoptionDate'] as Timestamp?)?.toDate(),
      photoURL: map['photoURL'],
      measurements: map['measurements'] != null
          ? PetMeasurements.fromMap(map['measurements'])
          : null,
      foods: (map['foods'] as List<dynamic>?)
          ?.map((f) => PetFood.fromMap(f))
          .toList(),
      vaccinations: (map['vaccinations'] as List<dynamic>?)
          ?.map((v) => PetVaccination.fromMap(v))
          .toList(),
      ownerId: map['ownerId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Pet copyWith({
    String? name,
    String? species,
    DateTime? dateOfBirth,
    String? gender,
    DateTime? adoptionDate,
    String? photoURL,
    PetMeasurements? measurements,
    List<PetFood>? foods,
    List<PetVaccination>? vaccinations,
  }) {
    return Pet(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      photoURL: photoURL ?? this.photoURL,
      measurements: measurements ?? this.measurements,
      foods: foods ?? this.foods,
      vaccinations: vaccinations ?? this.vaccinations,
      ownerId: ownerId,
      createdAt: createdAt,
    );
  }
}

class PetMeasurements {
  final double weight; // in kg
  final double height; // in cm
  final double length; // in cm

  PetMeasurements({
    required this.weight,
    required this.height,
    required this.length,
  });

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'height': height,
      'length': length,
    };
  }

  factory PetMeasurements.fromMap(Map<String, dynamic> map) {
    return PetMeasurements(
      weight: (map['weight'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
      length: (map['length'] ?? 0.0).toDouble(),
    );
  }
}

class PetFood {
  final String name;
  final double energyPerGram; // in kcal/g

  PetFood({
    required this.name,
    required this.energyPerGram,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'energyPerGram': energyPerGram,
    };
  }

  factory PetFood.fromMap(Map<String, dynamic> map) {
    return PetFood(
      name: map['name'] ?? '',
      energyPerGram: (map['energyPerGram'] ?? 0.0).toDouble(),
    );
  }
}

class PetVaccination {
  final String name;
  final DateTime date;
  final DateTime? nextDueDate;

  PetVaccination({
    required this.name,
    required this.date,
    this.nextDueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date),
      'nextDueDate': nextDueDate != null ? Timestamp.fromDate(nextDueDate!) : null,
    };
  }

  factory PetVaccination.fromMap(Map<String, dynamic> map) {
    return PetVaccination(
      name: map['name'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      nextDueDate: (map['nextDueDate'] as Timestamp?)?.toDate(),
    );
  }
} 