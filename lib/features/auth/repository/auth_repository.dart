import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../model/register_model.dart';

abstract class IAuthRepository {
  Future<void> register(RegisterModel model);

  Future<bool> login({required String name, required String password});
  Future<bool> checkAuthStatus();
  Future<void> logout();
}

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> register(RegisterModel model) async {
    UserCredential? userCredential;

    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: model.email.trim(),
        password: model.password.trim(),
      );

      final String uid = userCredential.user!.uid;

      final updatedModelMap = model.toFirestoreMap(uid);
      updatedModelMap['fcmToken'] = fcmToken;

      await _firestore.collection('users').doc(uid).set(updatedModelMap);
      await userCredential.user!.updateDisplayName(
        "${model.name} ${model.surname}",
      );
      await _firebaseAuth.signOut();
    } catch (e) {
      if (userCredential?.user != null) {
        try {
          await userCredential!.user!.delete();
        } catch (_) {}
        await _firebaseAuth.signOut();
      }
      rethrow;
    }
  }

  @override
  Future<bool> login({required String name, required String password}) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('name', isEqualTo: name.trim())
          .get();

      if (query.docs.isEmpty) {
        return false;
      }

      final String email = query.docs.first.data()['email'] as String;

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> checkAuthStatus() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider(this._authRepository);

  Future<bool> signUp(RegisterModel model) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.register(model);
      return true;
    } catch (e) {
      print("Kayıt Hatası: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String name, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool isSuccess = await _authRepository.login(
        name: name,
        password: password,
      );
      return isSuccess;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isAuthenticated() async {
    return await _authRepository.checkAuthStatus();
  }

  Future<void> signOut() async {
    await _authRepository.logout();
    notifyListeners();
  }
}
