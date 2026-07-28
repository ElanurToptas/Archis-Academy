class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException()
      : super('Kullanıcı adı veya şifre hatalı.');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException()
      : super('Bu kullanıcı adı ile kayıtlı bir hesap bulunamadı.');
}

class WrongPasswordException extends AuthException {
  WrongPasswordException()
      : super('Şifre yanlış. Lütfen kontrol edip tekrar deneyin.');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException()
      : super('Şifre çok zayıf. En az 6 karakter kullanın.');
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException()
      : super('Bu e-posta adresi zaten kayıtlı.');
}

class InvalidEmailException extends AuthException {
  InvalidEmailException() : super('Geçersiz e-posta adresi.');
}

class NetworkException extends AuthException {
  NetworkException() : super('İnternet bağlantısı bulunamadı. Lütfen tekrar deneyin.');
}

class TooManyRequestsException extends AuthException {
  TooManyRequestsException()
      : super('Çok fazla deneme yapıldı. Lütfen kısa süre sonra tekrar deneyin.');
}