class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException()
      : super('Incorrect username or password.');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException()
      : super('No account found with this username.');
}

class WrongPasswordException extends AuthException {
  WrongPasswordException()
      : super('Password is incorrect. Please check and try again.');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException()
      : super('Password is too weak. Please use at least 6 characters.');
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException()
      : super('An account with this email address already exists.');
}

class InvalidEmailException extends AuthException {
  InvalidEmailException() : super('Invalid email address.');
}

class NetworkException extends AuthException {
  NetworkException() : super('No internet connection. Please try again.');
}

class TooManyRequestsException extends AuthException {
  TooManyRequestsException()
      : super('Too many attempts. Please try again later.');
}