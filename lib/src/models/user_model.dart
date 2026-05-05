import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.degree,
    this.photoUrl,
    this.interests,
    this.createdAt,
  });

  final String uid;
  final String? email;
  String? displayName;
  String? degree;
  String? photoUrl;
  List<String>? interests;
  DateTime? createdAt;

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'degree': degree,
    'photoUrl': photoUrl,
    'interests': interests ?? [],
    'createdAt': createdAt?.toUtc(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      degree: map['degree'],
      photoUrl: map['photoUrl'],
      interests: (map['interests'] as List<dynamic>?)?.cast<String>(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] is String
          ? DateTime.tryParse(map['createdAt'])
          : null,
    );
  }
}
