package com.nonstopio.contact.permission.contact_permission

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

/** ContactPermissionPlugin */
class ContactPermissionPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private val permissionCode: Int = 0
    private var permissionResult: Result? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "nonstopio_contact_permission")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
        binding.addActivityResultListener(this)
    }

    override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onDetachedFromActivity() {
        activity = null
    }


    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        when (requestCode) {
            permissionCode -> {
                val granted =
                    grantResults.size == 1 && grantResults[0] == PackageManager.PERMISSION_GRANTED
                if (permissionResult != null) {
                    GlobalScope.launch(Dispatchers.Main) {
                        permissionResult?.success(granted)
                        permissionResult = null
                    }
                }
                return true
            }
        }
        return false // did not handle the result
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "isPermissionGranted") {
            if (context == null) {
                result.error("UNAVAILABLE", "Context is null", null)
                return
            } else {
                if (ContextCompat.checkSelfPermission(
                        context!!,
                        Manifest.permission.READ_CONTACTS
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
        } else if (call.method == "requestPermission") {
            if (context == null) {
                result.error("UNAVAILABLE", "Context is null", null)
                return
            } else {
                if (ContextCompat.checkSelfPermission(
                        context!!,
                        Manifest.permission.READ_CONTACTS
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    result.success(true)
                } else {
                    if (activity != null) {
                        permissionResult = result
                        ActivityCompat.requestPermissions(
                            activity!!,
                            arrayOf(Manifest.permission.READ_CONTACTS),
                            permissionCode,
                        )
                    }else {
                        result.error("UNAVAILABLE", "Activity is null", null)
                    }
                }
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return false
    }
}
