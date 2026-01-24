/// Custom exceptions for the application
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

class AuthenticationException extends AppException {
  AuthenticationException({required super.message, super.code});
}

class ValidationException extends AppException {
  ValidationException({required super.message, super.code});
}

class NetworkException extends AppException {
  NetworkException({required super.message, super.code});
}

class ServerException extends AppException {
  ServerException({required super.message, super.code});
}

class NotFoundException extends AppException {
  NotFoundException({required super.message, super.code});
}

class LocationException extends AppException {
  LocationException({required super.message, super.code});
}

class PermissionException extends AppException {
  PermissionException({required super.message, super.code});
}
