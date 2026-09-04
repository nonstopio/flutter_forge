import 'package:network/src/auth/auth_token_provider.dart';

abstract class NetworkConfig {
  String get baseUrl;
  Duration get connectTimeout;
  Duration get receiveTimeout;
  Duration get sendTimeout;
  Map<String, String> get defaultHeaders;
  bool get enableLogging;
  AuthTokenProvider? get authTokenProvider;
}

class DefaultNetworkConfig implements NetworkConfig {
  const DefaultNetworkConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.defaultHeaders = const {},
    this.enableLogging = true,
    this.authTokenProvider,
  });

  @override
  final String baseUrl;

  @override
  final Duration connectTimeout;

  @override
  final Duration receiveTimeout;

  @override
  final Duration sendTimeout;

  @override
  final Map<String, String> defaultHeaders;

  @override
  final bool enableLogging;

  @override
  final AuthTokenProvider? authTokenProvider;
}
