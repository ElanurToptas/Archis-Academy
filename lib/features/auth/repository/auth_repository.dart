import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../auth_exceptions.dart';
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

  AuthException _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return WeakPasswordException();
      case 'email-already-in-use':
        return EmailAlreadyInUseException();
      case 'invalid-email':
        return InvalidEmailException();
      case 'network-request-failed':
        return NetworkException();
      case 'too-many-requests':
        return TooManyRequestsException();
      case 'operation-not-allowed':
        return AuthException('E-posta ve şifre girişi şu anda devre dışı.');
      default:
        return AuthException(
          'Kayıt işlemi başarısız oldu. ${e.message ?? 'Lütfen tekrar deneyin.'}',
        );
    }
  }

  @override
  Future<void> register(RegisterModel model) async {
    UserCredential? userCredential;

    try {
      String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {
      fcmToken = null; 
    }

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
    } on FirebaseAuthException catch (e) {
      if (userCredential?.user != null) {
        try {
          await userCredential!.user!.delete();
        } catch (_) {}
        await _firebaseAuth.signOut();
      }
      throw _mapAuthException(e);
    } catch (e) {
      if (userCredential?.user != null) {
        try {
          await userCredential!.user!.delete();
        } catch (_) {}
        await _firebaseAuth.signOut();
      }
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException();
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
        throw UserNotFoundException();
      }

      final String email = query.docs.first.data()['email'] as String;

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw WrongPasswordException();
        case 'user-not-found':
          throw UserNotFoundException();
        case 'invalid-email':
          throw InvalidEmailException();
        case 'user-disabled':
          throw AuthException('Bu hesap devre dışı bırakılmış.');
        case 'network-request-failed':
          throw NetworkException();
        case 'too-many-requests':
          throw TooManyRequestsException();
        default:
          throw AuthException(
            'Giriş yapılamadı. ${e.message ?? 'Lütfen tekrar deneyin.'}',
          );
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException();
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
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._authRepository);

  Future<bool> signUp(RegisterModel model) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(model);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Beklenmeyen bir hata oluştu.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String name, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool isSuccess = await _authRepository.login(
        name: name,
        password: password,
      );
      return isSuccess;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Beklenmeyen bir hata oluştu.';
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
