import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class IAuthRepository {
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String surname,
  });
  Future<bool> login({required String name, required String password});
  Future<bool> checkAuthStatus();
}

class AuthRepository implements IAuthRepository {
  final _secureStorage = const FlutterSecureStorage();
  @override
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    await _secureStorage.write(key: 'user_email', value: email);
    await _secureStorage.write(key: 'user_name', value: name);
    await _secureStorage.write(key: 'user_surname', value: surname);
    await _secureStorage.write(key: 'user_password', value: password);
    await _secureStorage.write(key: 'is_logged_in', value: 'true');
  }

  @override
  Future<bool> login({required String name, required String password}) async {
    final String? savedName = await _secureStorage.read(key: 'user_name');
    final String? savedPassword = await _secureStorage.read(
      key: 'user_password',
    );

    if (savedName == name && savedPassword == password) {
      await _secureStorage.write(key: 'is_logged_in', value: 'true');
      return true;
    }

    return false;
  }

  @override
  Future<bool> checkAuthStatus() async {
    final String? isLoggedIn = await _secureStorage.read(key: 'is_logged_in');
    return isLoggedIn == 'true';
  }
}

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider(this._authRepository);

  Future<bool> signUp(
    String name,
    String surname,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.register(
        email: email,
        password: password,
        name: name,
        surname: surname,
      );
      return true;
    } catch (e) {
      print("Hata: $e");
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
}
