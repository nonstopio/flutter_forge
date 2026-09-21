package io.flutter.embedding.engine.plugins
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
interface FlutterPlugin {
  class FlutterPluginBinding(val binaryMessenger: BinaryMessenger, val applicationContext: Context)
  fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding)
  fun onDetachedFromEngine(binding: FlutterPluginBinding)
}
