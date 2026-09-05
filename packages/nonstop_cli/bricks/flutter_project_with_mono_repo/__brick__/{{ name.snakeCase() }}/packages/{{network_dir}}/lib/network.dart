library;

import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:network/src/auth/index.dart';
import 'package:network/src/client/index.dart';
import 'package:network/src/config/index.dart';

export 'src/api/index.dart';
export 'src/auth/index.dart';
export 'src/client/index.dart';
export 'src/config/index.dart';
export 'src/exceptions/index.dart';
export 'src/interceptors/index.dart';
export 'src/models/index.dart';
export 'src/utils/index.dart';

Future<void> init({
  required NetworkConfig config,
  bool useAuthentication = true,
}) async {
  await registerNetworkWithDI(config, useAuthentication: useAuthentication);
  final logger = di.get<Logger>();
  logger.i('Network module initialized with base URL: ${config.baseUrl}');
}

Future<void> registerNetworkWithDI(
  NetworkConfig config, {
  bool useAuthentication = true,
}) async {
  final logger = di.get<Logger>();

  // Try to get AuthTokenProvider from DI if authentication is enabled
  AuthTokenProvider? authTokenProvider;
  if (useAuthentication && config.authTokenProvider == null) {
    try {
      authTokenProvider = di.get<AuthTokenProvider>();
      logger.d('🔐 Found AuthTokenProvider in DI, using for authentication');
    } catch (e) {
      logger.d(
        '🔓 No AuthTokenProvider found in DI, creating unauthenticated client',
      );
    }
  } else if (config.authTokenProvider != null) {
    authTokenProvider = config.authTokenProvider;
    logger.d('🔐 Using provided AuthTokenProvider');
  }

  // Create network config with auth provider if available
  late final NetworkConfig finalConfig;
  if (authTokenProvider != null && config.authTokenProvider == null) {
    // Create a new config with the auth provider
    finalConfig = DefaultNetworkConfig(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      defaultHeaders: config.defaultHeaders,
      enableLogging: config.enableLogging,
      authTokenProvider: authTokenProvider,
    );
  } else {
    finalConfig = config;
  }

  final networkClient = DioNetworkClient(finalConfig);
  di.register<NetworkClient>(
    networkClient,
    dispose: (client) => client.dispose(),
  );
  di.register<NetworkConfig>(finalConfig);

  if (finalConfig.authTokenProvider != null) {
    logger.i('🔐 Network client registered with authentication support');
  } else {
    logger.i('🔓 Network client registered without authentication');
  }
}
