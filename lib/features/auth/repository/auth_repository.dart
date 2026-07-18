import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IAuthRepository {
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String surname,
  });
  Future<bool> login({required String name, required String password});
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
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_email', email);
    await prefs.setString('user_name', name);
    await prefs.setString('user_surname', surname);
    await prefs.setBool('is_logged_in', true);

    await _secureStorage.write(key: 'user_password', value: password);
  }

  @override
  Future<bool> login({required String name, required String password}) async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedPassword = await _secureStorage.read(
      key: 'user_password',
    );
    final String? savedName = prefs.getString('user_name');

    if (savedName == name && savedPassword == password) {
      await prefs.setBool('is_logged_in', true);
      return true;
    }
    return false;
  }
}

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider(this._authRepository);

  Future<bool> signUp(String name, String surname, String email, String password) async {
   _isLoading = true;
    notifyListeners();

  try {
    await _authRepository.register(
      email: email, 
      password: password, 
      name: name,
      surname: surname
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
}
