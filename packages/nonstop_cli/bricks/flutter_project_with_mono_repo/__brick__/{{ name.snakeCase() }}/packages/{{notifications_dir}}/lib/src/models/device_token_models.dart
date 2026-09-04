import 'package:json_annotation/json_annotation.dart';

part 'device_token_models.g.dart';

@JsonSerializable()
class DeviceTokenRequest {
  final String fcmToken;
  final String deviceId;
  final String deviceName;
  final String deviceType;

  const DeviceTokenRequest({
    required this.fcmToken,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
  });

  factory DeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceTokenRequestToJson(this);
}

@JsonSerializable()
class DeviceTokenUpdateRequest {
  final String fcmToken;

  const DeviceTokenUpdateRequest({required this.fcmToken});

  factory DeviceTokenUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceTokenUpdateRequestToJson(this);
}
