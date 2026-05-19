enum AuthStatus { checking, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? userName;
  final String? userEmail;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.userName,
    this.userEmail,
    this.errorMessage,
  });

  factory AuthState.checking() => AuthState(status: AuthStatus.checking);
  
  factory AuthState.authenticating() => AuthState(status: AuthStatus.authenticating);
  
  factory AuthState.unauthenticated() => AuthState(status: AuthStatus.unauthenticated);
  
  factory AuthState.authenticated({required String userName, required String userEmail}) => 
      AuthState(status: AuthStatus.authenticated, userName: userName, userEmail: userEmail);
      
  factory AuthState.error(String message) => 
      AuthState(status: AuthStatus.error, errorMessage: message);

  bool get isChecking => status == AuthStatus.checking;
  bool get isAuthenticating => status == AuthStatus.authenticating;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isError => status == AuthStatus.error;
}
