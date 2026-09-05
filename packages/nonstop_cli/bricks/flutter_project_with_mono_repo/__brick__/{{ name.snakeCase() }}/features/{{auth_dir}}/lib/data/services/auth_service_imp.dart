import 'package:auth/analytics/analytics.dart';
import 'package:auth/data/services/auth_service.dart';
import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServiceImp implements AuthService {
  final _logger = di.get<Logger>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
      AuthAnalytics.logSignOutSuccess();
    } catch (e, s) {
      _logger.e('Error signing out user: $e', e, s);

      // Log sign out error
      AuthAnalytics.logSignOutError(errorMessage: e.toString());

      rethrow;
    }
  }
}
