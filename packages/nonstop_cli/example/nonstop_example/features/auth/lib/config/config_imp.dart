import 'package:auth/config/config.dart';

class DefaultAuthConfig implements AuthConfig {
  @override
  final String clientId;

  DefaultAuthConfig({required this.clientId});
}
