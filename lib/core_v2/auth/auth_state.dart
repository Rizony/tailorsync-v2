enum AuthStatus {
  unauthenticated,
  authenticated,
  loading,
}

class AuthState {
  final AuthStatus status;
  final String? userId;

  const AuthState._(this.status, this.userId);
  

  const AuthState.unauthenticated()
      : this._(AuthStatus.unauthenticated, null);

  const AuthState.loading()
      : this._(AuthStatus.loading, null);

  const AuthState.authenticated(String userId)
      : this._(AuthStatus.authenticated, userId);
}
