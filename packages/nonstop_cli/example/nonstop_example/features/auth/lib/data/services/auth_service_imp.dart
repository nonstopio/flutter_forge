import 'package:auth/analytics/analytics.dart';
import 'package:auth/data/services/auth_service.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServiceImp implements AuthService {
  AuthServiceImp({required FirebaseAuth firebaseAuth, required Logger logger})
    : _firebaseAuth = firebaseAuth,
      _logger = logger;

  final Logger _logger;
  final FirebaseAuth _firebaseAuth;

  @override
  String get uid => _firebaseAuth.currentUser?.uid ?? '';

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  Future<void> signOut() async {
    try {
      _logger.d('Attempting to sign out user');
      await _firebaseAuth.signOut();
      _logger.d('User signed out successfully');

      // Log successful sign out
      await AuthAnalytics.logSignOutSuccess();
    } catch (e, s) {
      _logger.e('Error signing out user: $e', e, s);

      // Log sign out error
      await AuthAnalytics.logSignOutError(errorMessage: e.toString());

      rethrow;
    }
  }
}
