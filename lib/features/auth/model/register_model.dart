// lib/features/auth/model/register_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterModel {
  final String name;
  final String surname;
  final String email;
  final String password;
  final String? fcmToken;

  RegisterModel({
    required this.name,
    required this.surname,
    required this.email,
    required this.password,
    this.fcmToken,
  });

  Map<String, dynamic> toFirestoreMap(String uid) {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'email': email,
      'fcmToken': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}