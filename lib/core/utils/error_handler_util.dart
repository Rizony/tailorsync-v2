import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/exceptions.dart' hide AuthException;
import '../errors/failures.dart';

class ErrorHandler {
  static Failure handle(Object error, [StackTrace? stackTrace]) {
    // Log error here if logging service is available
    // print('Error: $error'); 
    // print('Stack: $stackTrace');

    if (error is AuthException) {
      if (error.message.contains('Invalid login credentials')) {
        return const AuthFailure('Invalid email or password. Please try again.');
      }
      if (error.message.contains('User already registered')) {
        return const AuthFailure('An account with this email already exists.');
      }
      return AuthFailure(error.message);
    } 
    
    if (error is PostgrestException) {
      // Map common database errors
      if (error.code == '23505') { // unique_violation
        return const ServerFailure('This record already exists.');
      }
      if (error.code == '23503') { // foreign_key_violation
        return const ServerFailure('The referenced record could not be found.');
      }
      if (error.code == '23502') { // not_null_violation
        return const ServerFailure('Please provide all required fields.');
      }
      if (error.code == '42P01') { // undefined_table
        return const ServerFailure('We encountered an issue with the server structure. Please report this.');
      }
      // Provide a generic but friendly message for other DB errors
      return const ServerFailure('A database error occurred. Please try again.');
    }
    
    if (error is StorageException) {
      if (error.message.contains('Payload too large')) {
         return const ServerFailure('The file is too large to upload.');
      }
      if (error.message.contains('mime')) {
         return const ServerFailure('Unsupported file type.');
      }
      return const ServerFailure('Could not upload the file. Please try again.');
    }
    
    if (error is FunctionException) {
      return const ServerFailure('An error occurred while processing your request in the background.');
    }

    if (error is AppException) {
      return ServerFailure(error.message);
    }

    if (error is Failure) {
      return error;
    }

    // Generic fallback for any other unknown errors
    return const ServerFailure('An unexpected error occurred. Please try again later.');
  }
}
