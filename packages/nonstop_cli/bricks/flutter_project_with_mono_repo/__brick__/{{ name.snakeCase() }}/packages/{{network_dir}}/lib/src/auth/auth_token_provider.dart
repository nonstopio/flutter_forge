abstract class AuthTokenProvider {
  /// Gets a valid authentication token
  /// Returns null if user is not authenticated
  Future<String?> getValidToken();

  /// Gets the current token without validation
  /// Returns null if no token is available
  String? getCurrentToken();

  /// Stream of authentication token changes
  /// Emits new tokens when authentication state changes
  Stream<String?> get tokenStream;

  /// Forces a token refresh
  /// Returns the new token or null if refresh fails
  Future<String?> refreshToken();

  /// Checks if the user is currently authenticated
  bool get isAuthenticated;

  /// Checks if the current token is expired
  /// Returns true if token is null or expired
  bool get isTokenExpired;

  /// Sign out the current user
  Future<void> signOut();
}
