abstract class ApiUrlConfig {
  final String pathPrefix;

  const ApiUrlConfig({required this.pathPrefix});
}

abstract class NetworkApi<T extends ApiUrlConfig> {
  final T urlConfig;

  const NetworkApi({required this.urlConfig});

  Map<String, String> get headers;
}
