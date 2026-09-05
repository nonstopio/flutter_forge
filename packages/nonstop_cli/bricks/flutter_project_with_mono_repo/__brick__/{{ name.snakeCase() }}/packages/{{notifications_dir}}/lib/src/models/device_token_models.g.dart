// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceTokenRequest _$DeviceTokenRequestFromJson(Map<String, dynamic> json) =>
    DeviceTokenRequest(
      fcmToken: json['fcmToken'] as String,
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      deviceType: json['deviceType'] as String,
    );

Map<String, dynamic> _$DeviceTokenRequestToJson(DeviceTokenRequest instance) =>
    <String, dynamic>{
      'fcmToken': instance.fcmToken,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'deviceType': instance.deviceType,
    };

DeviceTokenUpdateRequest _$DeviceTokenUpdateRequestFromJson(
  Map<String, dynamic> json,
) => DeviceTokenUpdateRequest(fcmToken: json['fcmToken'] as String);

Map<String, dynamic> _$DeviceTokenUpdateRequestToJson(
  DeviceTokenUpdateRequest instance,
) => <String, dynamic>{'fcmToken': instance.fcmToken};
