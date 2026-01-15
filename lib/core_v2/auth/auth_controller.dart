import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState.loading()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // TEMP: simulate local user
    await Future.delayed(const Duration(milliseconds: 400));
    state = const AuthState.authenticated('local_user');
  }

  void signOut() {
    state = const AuthState.unauthenticated();
  }

  void signIn(String userId) {
    state = AuthState.authenticated(userId);
  }
}
