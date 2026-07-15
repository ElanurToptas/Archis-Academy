import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IAuthRepository {
  Future<void> register({required String email, required String password, required String name, required String surname});
  Future<bool> login({required String name, required String password});
  Future<bool> checkAuthStatus(); 
}

class AuthRepository implements IAuthRepository {
  @override
  Future<void> register({required String email, required String password, required String name, required String surname}) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', name);
    await prefs.setString('user_surname', surname);
    await prefs.setString('user_password', password);
    await prefs.setBool('is_logged_in', true);
  }

   @override
  Future<bool> login({required String name, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? savedName = prefs.getString('user_name');
    final String? savedPassword = prefs.getString('user_password'); 


    return (savedName == name && savedPassword == password);
  }

  @override
  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance(); 
    return prefs.getBool('is_logged_in') ?? false;
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

  Future<bool> signIn(String name, String password) async {
  _isLoading = true;
  notifyListeners();

  try {
    bool isSuccess = await _authRepository.login(name: name, password: password);
    return isSuccess;
  } catch (e) {
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<bool> get isAuthenticated async {
  return await _authRepository.checkAuthStatus();
}
}