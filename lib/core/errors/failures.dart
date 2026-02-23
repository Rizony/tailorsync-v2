import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Represents a failure from the server or API (Supabase)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'An unexpected error occurred']);
}

/// Represents a failure from local storage or cache
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

/// Represents an authentication failure
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

/// Represents a validation failure
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}
