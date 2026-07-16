class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super("Kullanıcı adı veya şifre hatalı.");
}

class NetworkException extends AuthException {
  NetworkException() : super("Bağlantı hatası, lütfen tekrar deneyin.");
}