/// Base class for all app exceptions
class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Thrown when a server or API call fails
class ServerException extends AppException {
  ServerException(super.message, {super.code});
}

/// Thrown when a local cache operation fails
class CacheException extends AppException {
  CacheException(super.message, {super.code});
}

/// Thrown when authentication fails
class AuthException extends AppException {
  AuthException(super.message, {super.code});
}
