import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import com.nonstopio.contact.permission.contact_permission.ContactPermissionPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import kotlin.test.*

@OptIn(ExperimentalCoroutinesApi::class)
class ContactPermissionPluginTest {
    private lateinit var scheduler: TestCoroutineScheduler
    private class Result : MethodChannel.Result {
        val values = mutableListOf<Any?>()
        val errors = mutableListOf<String?>()
        var unsupported = false
        override fun success(result: Any?) { values.add(result) }
        override fun error(code: String, message: String?, details: Any?) {
            assertEquals<Any?>("UNAVAILABLE", code)
            assertNull(details)
            errors.add(message)
        }
        override fun notImplemented() { unsupported = true }
    }

    @BeforeTest fun reset() {
        ActivityCompat.requests.clear()
        scheduler = TestCoroutineScheduler()
        Dispatchers.setMain(StandardTestDispatcher(scheduler))
    }

    @AfterTest fun restoreDispatcher() { Dispatchers.resetMain() }

    private fun attach(plugin: ContactPermissionPlugin, context: Context): FlutterPlugin.FlutterPluginBinding {
        val binding = FlutterPlugin.FlutterPluginBinding(object : BinaryMessenger {}, context)
        plugin.onAttachedToEngine(binding)
        assertEquals<Any?>("nonstopio_contact_permission", MethodChannel.latest!!.name)
        assertSame(plugin, MethodChannel.latest!!.handler)
        return binding
    }

    @Test fun unavailableContextsAndUnknownMethod() {
        val plugin = ContactPermissionPlugin()
        for (method in listOf("isPermissionGranted", "requestPermission")) {
            val result = Result()
            plugin.onMethodCall(MethodCall(method), result)
            assertEquals<Any?>(listOf("Context is null"), result.errors)
        }
        val result = Result()
        plugin.onMethodCall(MethodCall("unknown"), result)
        assertTrue(result.unsupported)
    }

    @Test fun grantedDeniedAndMissingActivity() {
        val plugin = ContactPermissionPlugin()
        val context = Context()
        val binding = attach(plugin, context)
        for (granted in listOf(false, true)) {
            context.permission = if (granted) PackageManager.PERMISSION_GRANTED else -1
            val result = Result()
            plugin.onMethodCall(MethodCall("isPermissionGranted"), result)
            assertEquals<Any?>(listOf(granted), result.values)
            val request = Result()
            plugin.onMethodCall(MethodCall("requestPermission"), request)
            if (granted) assertEquals<Any?>(listOf(true), request.values)
            else assertEquals<Any?>(listOf("Activity is null"), request.errors)
        }
        plugin.onDetachedFromEngine(binding)
        assertNull(MethodChannel.latest!!.handler)
    }

    @Test fun activityLifecycleAndPermissionCallbacks() {
        val plugin = ContactPermissionPlugin()
        attach(plugin, Context())
        val activity = ActivityPluginBinding(Activity())
        plugin.onAttachedToActivity(activity)
        assertEquals<Any?>(listOf(plugin), activity.permissionListeners)
        assertEquals<Any?>(listOf(plugin), activity.activityListeners)
        assertFalse(plugin.onActivityResult(0, 0, Intent()))
        assertFalse(plugin.onRequestPermissionsResult(99, emptyArray(), intArrayOf(0)))
        assertTrue(plugin.onRequestPermissionsResult(0, emptyArray(), intArrayOf(0)))
        scheduler.runCurrent()
        for (results in listOf(intArrayOf(0), intArrayOf(-1), intArrayOf(), intArrayOf(0, 0))) {
            val result = Result()
            plugin.onMethodCall(MethodCall("requestPermission"), result)
            val request = ActivityCompat.requests.last()
            assertSame(activity.activity, request.activity)
            assertContentEquals(arrayOf(Manifest.permission.READ_CONTACTS), request.permissions)
            assertEquals<Any?>(0, request.code)
            assertTrue(plugin.onRequestPermissionsResult(0, request.permissions, results))
            assertTrue(result.values.isEmpty(), "Reply must be dispatched on the main queue")
            scheduler.runCurrent()
            assertEquals<Any?>(listOf(results.contentEquals(intArrayOf(0))), result.values)
            plugin.onRequestPermissionsResult(0, request.permissions, results)
            scheduler.runCurrent()
            assertEquals<Any?>(1, result.values.size, "A result is completed only once")
        }
        plugin.onDetachedFromActivityForConfigChanges()
        val detached = Result()
        plugin.onMethodCall(MethodCall("requestPermission"), detached)
        assertEquals<Any?>(listOf("Activity is null"), detached.errors)
        val replacement = ActivityPluginBinding(Activity())
        plugin.onReattachedToActivityForConfigChanges(replacement)
        assertEquals<Any?>(listOf(plugin), replacement.permissionListeners)
        assertEquals<Any?>(listOf(plugin), replacement.activityListeners)
        plugin.onDetachedFromActivity()
        val noActivity = Result()
        plugin.onMethodCall(MethodCall("requestPermission"), noActivity)
        assertEquals<Any?>(listOf("Activity is null"), noActivity.errors)
    }
}
