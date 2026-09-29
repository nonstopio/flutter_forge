library;

import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:dio/dio.dart';
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

/// Registers [NetworkClient] and the caller's own [config] instance.
///
/// When [useAuthentication] is true, credentials come from
/// [NetworkConfig.authTokenProvider] or, failing that, from an
/// [AuthTokenProvider] registered in DI (for example by the auth feature).
Future<void> registerNetworkWithDI(
  NetworkConfig config, {
  bool useAuthentication = true,
  Dio? dio,
}) async {
  final logger = di.get<Logger>();

  final authTokenProvider = !useAuthentication
      ? null
      : config.authTokenProvider ??
            (di.has<AuthTokenProvider>() ? di.get<AuthTokenProvider>() : null);

  final networkClient = DioNetworkClient(
    config,
    logger: logger,
    dio: dio,
    authTokenProvider: authTokenProvider,
    useAuthentication: useAuthentication,
  );
  di.register<NetworkClient>(
    networkClient,
    dispose: (client) => client.dispose(),
  );
  di.register<NetworkConfig>(config);

  logger.i(
    authTokenProvider != null
        ? 'Network client registered with authentication support'
        : 'Network client registered without authentication',
  );
}
