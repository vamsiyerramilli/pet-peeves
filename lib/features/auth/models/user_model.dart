import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profilePicURL;
  final bool onboardingComplete;
  final List<String> pets;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profilePicURL,
    this.onboardingComplete = false,
    this.pets = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePicURL: data['profilePicURL'],
      onboardingComplete: data['onboardingComplete'] ?? false,
      pets: List<String>.from(data['pets'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePicURL': profilePicURL,
      'onboardingComplete': onboardingComplete,
      'pets': pets,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? profilePicURL,
    bool? onboardingComplete,
    List<String>? pets,
  }) {
    return UserModel(
      uid: this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicURL: profilePicURL ?? this.profilePicURL,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      pets: pets ?? this.pets,
    );
  }
} 