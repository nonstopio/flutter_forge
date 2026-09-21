package androidx.core.app
import android.app.Activity
object ActivityCompat {
  data class Request(val activity: Activity, val permissions: Array<String>, val code: Int)
  val requests = mutableListOf<Request>()
  fun requestPermissions(activity: Activity, permissions: Array<String>, code: Int) {
    requests.add(Request(activity, permissions, code))
  }
}
