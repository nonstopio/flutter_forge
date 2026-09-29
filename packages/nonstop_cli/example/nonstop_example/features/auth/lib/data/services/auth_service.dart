abstract interface class AuthService {
  String get uid;

  bool get isSignedIn;

  Future<void> signOut();
}
