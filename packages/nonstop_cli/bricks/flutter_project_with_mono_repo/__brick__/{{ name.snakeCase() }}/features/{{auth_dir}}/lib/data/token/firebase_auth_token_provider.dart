{{#network}}import 'dart:async';

import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:network/network.dart';

final _tag = 'FirebaseAuthTokenProvider';

class FirebaseAuthTokenProvider implements AuthTokenProvider {
  FirebaseAuthTokenProvider() : _logger = di.get<Logger>() {
    _initializeTokenStream();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Logger _logger;

  late final StreamController<String?> _tokenController;
  StreamSubscription<User?>? _authStateSubscription;
  String? _cachedToken;
  DateTime? _tokenExpiry;

  void _initializeTokenStream() {
    _tokenController = StreamController<String?>.broadcast();

    // Listen to auth state changes
    _authStateSubscription = _firebaseAuth.authStateChanges().listen(
      (User? user) async {
        if (user != null) {
          try {
            final token = await user.getIdToken();
            _cachedToken = token;
            _setTokenExpiry(token!);
            _tokenController.add(token);
            _logger.d('🔐$_tag: Auth token updated for user: ${user.uid}');
          } catch (e, s) {
            _logger.e(
              '🚨$_tag: Error getting token for user: ${user.uid}',
              e,
              s,
            );
            _cachedToken = null;
            _tokenExpiry = null;
            _tokenController.add(null);
          }
        } else {
          _cachedToken = null;
          _tokenExpiry = null;
          _tokenController.add(null);
          _logger.d('🔓$_tag: User signed out, token cleared');
        }
      },
      onError: (e, s) {
        _logger.e('🚨 $_tag: Auth state change error', e, s);
        _tokenController.add(null);
      },
    );
  }

  void _setTokenExpiry(String token) {
    try {
      // Firebase ID tokens are typically valid for 1 hour
      // We'll refresh 5 minutes before expiry
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 55));
    } catch (e) {
      _logger.w('⚠️$_tag: Could not determine token expiry, using default $e');
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 55));
    }
  }

  @override
  Future<String?> getValidToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      _logger.d('🔓$_tag: No authenticated user available');
      return null;
    }

    // Check if cached token is still valid
    if (_cachedToken != null && !isTokenExpired) {
      _logger.d('🔐$_tag: Using cached token');
      return _cachedToken;
    }

    // Get fresh token
    try {
      _logger.d('🔄$_tag: Fetching fresh token for user: ${user.uid}');
      final token = await user.getIdToken(true); // Force refresh
      _cachedToken = token;
      _setTokenExpiry(token!);
      _tokenController.add(token);
      return token;
    } catch (e, s) {
      _logger.e('🚨$_tag: Error getting fresh token', e, s);
      _cachedToken = null;
      _tokenExpiry = null;
      return null;
    }
  }

  @override
  String? getCurrentToken() {
    return _cachedToken;
  }

  @override
  Stream<String?> get tokenStream => _tokenController.stream;

  @override
  Future<String?> refreshToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      _logger.w('🔓$_tag: Cannot refresh token - no authenticated user');
      return null;
    }

    try {
      _logger.d('🔄$_tag: Refreshing token for user: ${user.uid}');
      final token = await user.getIdToken(true); // Force refresh
      _cachedToken = token;
      _setTokenExpiry(token!);
      _tokenController.add(token);
      _logger.i('✅$_tag: Token refreshed successfully');
      return token;
    } catch (e, s) {
      _logger.e('🚨$_tag: Token refresh failed', e, s);
      _cachedToken = null;
      _tokenExpiry = null;
      _tokenController.add(null);
      return null;
    }
  }

  @override
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  @override
  bool get isTokenExpired {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!);
  }

  @override
  Future<void> signOut() async {
    try {
      _logger.d('🔓$_tag: Signing out user');
      await _firebaseAuth.signOut();
      _cachedToken = null;
      _tokenExpiry = null;
      _tokenController.add(null);
      _logger.i('✅$_tag: User signed out successfully');
    } catch (e, s) {
      _logger.e('🚨$_tag: Error signing out user', e, s);
      rethrow;
    }
  }

  void dispose() {
    _authStateSubscription?.cancel();
    _tokenController.close();
    _logger.d('🧹$_tag: disposed');
  }
}{{/network}}
