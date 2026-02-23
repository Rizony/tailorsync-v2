import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tailorsync_v2/core/utils/error_handler_util.dart';

part 'auth_repository.g.dart';

@riverpod
class AuthRepository extends _$AuthRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<User?> build() async {
    return _supabase.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.tailorsync://login-callback/',
      );
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.tailorsync://login-callback/',
      );
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  /// Deletes all user data via a Supabase DB function, then signs out.
  /// Requires the `delete_user` RPC function to be created in Supabase
  /// (see Supabase SQL Editor setup instructions).
  Future<void> deleteAccount() async {
    try {
      // Call the RPC function that deletes all user data including auth record
      await _supabase.rpc('delete_user');
      // Sign out locally (session is already gone on server)
      await _supabase.auth.signOut();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
