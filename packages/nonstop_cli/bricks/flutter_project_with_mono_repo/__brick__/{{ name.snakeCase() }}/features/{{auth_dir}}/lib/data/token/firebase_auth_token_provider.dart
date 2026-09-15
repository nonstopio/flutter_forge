{{#network}}import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:network/network.dart';

/// Adapts Firebase tokens to the network contract and owns its subscription.
class FirebaseAuthTokenProvider implements AuthTokenProvider {
  FirebaseAuthTokenProvider({
    required FirebaseAuth firebaseAuth,
    required Logger logger,
    DateTime Function()? now,
  }) : _auth = firebaseAuth,
       _logger = logger,
       _now = now ?? DateTime.now {
    _subscription = _auth.idTokenChanges().listen(
      (user) {
        _revision++;
        _publish(null);
        if (user != null) unawaited(_readToken(user, force: false));
      },
      onError: (Object error, StackTrace stackTrace) {
        _revision++;
        _publish(null);
        _logger.e('Auth token stream failed', error, stackTrace);
      },
    );
  }

  final FirebaseAuth _auth;
  final Logger _logger;
  final DateTime Function() _now;
  final _controller = StreamController<String?>.broadcast();
  late final StreamSubscription<User?> _subscription;
  String? _token;
  DateTime? _expiry;
  int _revision = 0;
  bool _disposed = false;

  void _publish(String? token, [DateTime? expiry]) {
    if (_disposed) return;
    _token = token;
    _expiry = expiry;
    _controller.add(token);
  }

  Future<String?> _readToken(User user, {required bool force}) async {
    final revision = _revision;
    try {
      final result = await user.getIdTokenResult(force);
      // A late refresh from an old session must never restore its token.
      if (_disposed ||
          revision != _revision ||
          _auth.currentUser?.uid != user.uid) {
        return null;
      }
      _publish(result.token, result.expirationTime);
      return result.token;
    } catch (error, stackTrace) {
      if (!_disposed && revision == _revision) {
        _publish(null);
        _logger.e('Unable to read authentication token', error, stackTrace);
      }
      return null;
    }
  }

  @override
  Future<String?> getValidToken() async {
    final user = _auth.currentUser;
    if (_disposed || user == null) return null;
    if (_token != null && !isTokenExpired) return _token;
    return _readToken(user, force: false);
  }

  @override
  Future<String?> refreshToken() async {
    final user = _auth.currentUser;
    if (_disposed || user == null) return null;
    return _readToken(user, force: true);
  }

  @override
  String? getCurrentToken() => _token;

  @override
  Stream<String?> get tokenStream => _controller.stream;

  @override
  bool get isAuthenticated => !_disposed && _auth.currentUser != null;

  @override
  bool get isTokenExpired =>
      _expiry == null ||
      !_now().isBefore(_expiry!.subtract(const Duration(minutes: 5)));

  @override
  Future<void> signOut() async {
    _revision++;
    _publish(null);
    await _auth.signOut();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _revision++;
    _token = null;
    _expiry = null;
    await _subscription.cancel();
    await _controller.close();
  }
}
{{/network}}
