import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IAuthRepository {
  Future<void> register({required String email, required String password, required String name, required String surname});
}

class AuthRepository implements IAuthRepository {
  @override
  Future<void> register({required String email, required String password, required String name, required String surname}) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', name);
    await prefs.setString('user_surname', surname);
    await prefs.setBool('is_logged_in', true);
    
    print("Veri yerel olarak kaydedildi: $email");
  }
}

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider(this._authRepository);

  Future<void> signUp(String name, String surname, String email, String password) async {
    _isLoading = true;
    notifyListeners();

  try {
    await _authRepository.register(
      email: email, 
      password: password, 
      name: name,
      surname: surname
    );
  } catch (e) {
    print("Hata: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
  }
}