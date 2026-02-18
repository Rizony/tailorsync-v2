import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<AuthState> build() {
    return Supabase.instance.client.auth.onAuthStateChange;
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}