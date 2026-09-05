{{#network}}import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:network/network.dart';

/// A widget that provides authentication headers to its child builder.
///
/// This widget automatically fetches the current authentication token
/// using the [AuthTokenProvider] from dependency injection and constructs
/// HTTP headers with the Bearer token.
///
/// Example usage:
/// ```dart
/// // Without token validation (default - faster, uses cached token)
/// AuthHeadersBuilder(
///   builder: (context, headers) {
///     return CachedNetworkImage(
///       imageUrl: imageUrl,
///       httpHeaders: headers,
///     );
///   },
/// )
///
/// // With token validation (ensures fresh token)
/// AuthHeadersBuilder(d
///   validateToken: true,
///   builder: (context, headers) {
///     return CachedNetworkImage(
///       imageUrl: imageUrl,
///       httpHeaders: headers,
///     );
///   },
/// )
/// ```
class AuthHeadersBuilder extends StatelessWidget {
  static final _logger = di.get<Logger>();

  /// Creates an [AuthHeadersBuilder].
  ///
  /// The [builder] function is called with the current [BuildContext] and
  /// a map of HTTP headers. If authentication fails or no token is available,
  /// an empty map is provided.
  ///
  /// If [validateToken] is true, the token will be validated and
  /// refreshed if needed. If false (default), the current cached token will be used
  /// without validation.
  const AuthHeadersBuilder({
    super.key,
    required this.builder,
    this.validateToken = false,
  });

  /// The builder function that receives the authentication headers.
  ///
  /// The headers map will contain:
  /// - 'Authorization': 'Bearer {token}' (if authenticated)
  /// - 'Content-Type': 'application/json'
  ///
  /// If no authentication token is available, an empty map {} is provided.
  final Widget Function(BuildContext context, Map<String, String> headers)
  builder;

  /// Whether to validate and potentially refresh the token.
  ///
  /// If true, uses [AuthTokenProvider.getValidToken] which validates
  /// the token and refreshes it if needed.
  /// If false (default), uses [AuthTokenProvider.getCurrentToken] which returns the
  /// cached token without validation.
  final bool validateToken;

  Map<String, String> _getSyncAuthHeaders() {
    try {
      final authTokenProvider = di.get<AuthTokenProvider>();
      final token = authTokenProvider.getCurrentToken();

      if (token != null) {
        return {'Authorization': 'Bearer $token'};
      }
    } catch (e) {
      _logger.e('Error getting auth headers: $e');
    }
    return {};
  }

  Future<Map<String, String>> _getAsyncAuthHeaders() async {
    try {
      final authTokenProvider = di.get<AuthTokenProvider>();
      final token = await authTokenProvider.getValidToken();

      if (token != null) {
        return {'Authorization': 'Bearer $token'};
      }
    } catch (e) {
      _logger.e('Error getting auth headers: $e');
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    // If validation is not needed, return synchronously without FutureBuilder
    if (!validateToken) {
      final headers = _getSyncAuthHeaders();
      return builder(context, headers);
    }

    // If validation is needed, use FutureBuilder
    return FutureBuilder<Map<String, String>>(
      future: _getAsyncAuthHeaders(),
      builder: (context, snapshot) {
        final headers = snapshot.data ?? {};
        return builder(context, headers);
      },
    );
  }
}{{/network}}
