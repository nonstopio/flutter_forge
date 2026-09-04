import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

void main() {
  test('DefaultNetworkConfig creates instance with provided values', () {
    const config = DefaultNetworkConfig(
      baseUrl: 'https://api.example.com',
      enableLogging: true,
    );

    expect(config.baseUrl, 'https://api.example.com');
    expect(config.enableLogging, true);
    expect(config.connectTimeout, const Duration(seconds: 30));
  });
}
