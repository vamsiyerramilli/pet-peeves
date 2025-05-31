import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender {
  male('Male'),
  female('Female'),
  preferNotToSay('Prefer not to say'),
  unsure('Unsure');

  final String displayName;
  const Gender(this.displayName);
}

enum Species {
  dog('Dog'),
  cat('Cat'),
  bird('Bird'),
  fish('Fish'),
  other('Other');

  final String displayName;
  const Species(this.displayName);
}

class PetModel {
  final String id;
  final String name;
  final String? profilePhotoUrl;
  final Species species;
  final String? otherSpecies; // For when species is 'other'
  final Gender gender;
  final DateTime? dateOfBirth;
  final DateTime? adoptionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  PetModel({
    required this.id,
    required this.name,
    this.profilePhotoUrl,
    required this.species,
    this.otherSpecies,
    required this.gender,
    this.dateOfBirth,
    this.adoptionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate age in years and months
  String get age {
    if (dateOfBirth == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(dateOfBirth!);
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    
    if (years > 0) {
      return months > 0 ? '$years years & $months months' : '$years years';
    }
    return '$months months';
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
      'species': species.toString().split('.').last,
      'otherSpecies': otherSpecies,
      'gender': gender.toString().split('.').last,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'adoptionDate': adoptionDate != null ? Timestamp.fromDate(adoptionDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PetModel(
      id: doc.id,
      name: data['name'] as String,
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      species: Species.values.firstWhere(
        (e) => e.toString().split('.').last == data['species'],
        orElse: () => Species.other,
      ),
      otherSpecies: data['otherSpecies'] as String?,
      gender: Gender.values.firstWhere(
        (e) => e.toString().split('.').last == data['gender'],
        orElse: () => Gender.unsure,
      ),
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      adoptionDate: (data['adoptionDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create a copy with updated fields
  PetModel copyWith({
    String? name,
    String? profilePhotoUrl,
    Species? species,
    String? otherSpecies,
    Gender? gender,
    DateTime? dateOfBirth,
    DateTime? adoptionDate,
  }) {
    return PetModel(
      id: id,
      name: name ?? this.name,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      species: species ?? this.species,
      otherSpecies: otherSpecies ?? this.otherSpecies,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 