import 'package:auth/config/config.dart';

class DefaultAuthConfig implements AuthConfig {
  @override
  String clientId;

  DefaultAuthConfig({required this.clientId});
}
