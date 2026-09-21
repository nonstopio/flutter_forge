package io.flutter.embedding.engine.plugins.activity
import android.app.Activity
import io.flutter.plugin.common.PluginRegistry
interface ActivityAware {
  fun onAttachedToActivity(binding: ActivityPluginBinding)
  fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding)
  fun onDetachedFromActivityForConfigChanges()
  fun onDetachedFromActivity()
}
class ActivityPluginBinding(val activity: Activity) {
  val permissionListeners = mutableListOf<PluginRegistry.RequestPermissionsResultListener>()
  val activityListeners = mutableListOf<PluginRegistry.ActivityResultListener>()
  fun addRequestPermissionsResultListener(listener: PluginRegistry.RequestPermissionsResultListener) { permissionListeners.add(listener) }
  fun addActivityResultListener(listener: PluginRegistry.ActivityResultListener) { activityListeners.add(listener) }
}
