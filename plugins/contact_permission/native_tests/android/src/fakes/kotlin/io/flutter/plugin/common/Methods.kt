package io.flutter.plugin.common
interface BinaryMessenger
class MethodCall(val method: String, val arguments: Any? = null)
class MethodChannel(val messenger: BinaryMessenger, val name: String) {
  companion object { var latest: MethodChannel? = null }
  init { latest = this }
  var handler: MethodCallHandler? = null
  fun setMethodCallHandler(value: MethodCallHandler?) { handler = value }
  interface MethodCallHandler { fun onMethodCall(call: MethodCall, result: Result) }
  interface Result { fun success(result: Any?); fun error(code: String, message: String?, details: Any?); fun notImplemented() }
}
interface PluginRegistry {
  interface ActivityResultListener { fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?): Boolean }
  interface RequestPermissionsResultListener { fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean }
}
