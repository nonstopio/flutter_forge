import Flutter
import UIKit
import Contacts

public class SwiftContactPermissionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nonstopio_contact_permission", binaryMessenger: registrar.messenger())
    let instance = SwiftContactPermissionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "isPermissionGranted":
                result(ContactPermissionHandler.isPermissionGranted())
             case "requestPermission":
                ContactPermissionHandler.requestPermission { granted in
                        result(granted)
                    }
            default:
                result(FlutterMethodNotImplemented)
        }
  }
}
