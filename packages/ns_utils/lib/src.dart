library ns_utils;

import 'services/shared_preferences/sp_service.dart';

export 'package:after_layout/after_layout.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:device_info_plus/device_info_plus.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:flutter_spinkit/flutter_spinkit.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:recase/recase.dart';
export 'package:visibility_detector/visibility_detector.dart';

export 'data_type/stackx.dart';
export 'extensions/context.dart';
export 'extensions/date_time.dart';
export 'extensions/double.dart';
export 'extensions/duration.dart';
export 'extensions/functions.dart';
export 'extensions/int.dart';
export 'extensions/list.dart';
export 'extensions/map.dart';
export 'extensions/string.dart';
export 'extensions/widgets/gesture_detector.dart';
export 'extensions/widgets/widgets.dart';
export 'methods/conversion.dart';
export 'methods/helper.dart';
export 'services/shared_preferences/sp_service.dart';
export 'utils/focus_detector.dart';
export 'utils/sizes.dart';
export 'widgets/spacers.dart';

typedef LogCallBack = void Function(
  Object object, [
  Object detail,
]);

typedef ErrorLogCallBack = void Function(
  Object object, [
  dynamic error,
  StackTrace stackTrace,
]);

void _appLogs(
  dynamic object, [
  Object detail = "",
]) {}

void _errorLogs(Object message, [dynamic error, StackTrace? stackTrace]) {}

LogCallBack appLogsNS = _appLogs;
ErrorLogCallBack errorLogsNS = _errorLogs;

class NSUtils {
  static NSUtils instance = NSUtils();

  Future<void> init({
    LogCallBack? appLogsFunction,
    ErrorLogCallBack? errorLogsFunction,
  }) async {
    if (appLogsFunction != null) {
      appLogsNS = appLogsFunction;
    }
    if (errorLogsFunction != null) {
      errorLogsNS = errorLogsFunction;
    }
    await SPService.init();
  }
}
