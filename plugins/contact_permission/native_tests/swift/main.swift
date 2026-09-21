import Foundation
import Contacts
import Flutter

final class Registrar: FlutterPluginRegistrar {
    let binaryMessenger = NSObject()
    var plugin: FlutterPlugin?
    var channel: FlutterMethodChannel?
    func messenger() -> NSObject { binaryMessenger }
    func addMethodCallDelegate(_ instance: FlutterPlugin, channel: FlutterMethodChannel) {
        plugin = instance
        self.channel = channel
    }
}

let registrar = Registrar()
SwiftContactPermissionPlugin.register(with: registrar)
precondition(registrar.channel!.name == "nonstopio_contact_permission")
precondition(registrar.channel!.binaryMessenger === registrar.binaryMessenger)
let plugin = registrar.plugin!

for status in [CNAuthorizationStatus.authorized, .denied, .restricted, .notDetermined, .limited] {
    CNContactStore.status = status
    var responses = [Bool]()
    plugin.handle(FlutterMethodCall(method: "isPermissionGranted")) { result in
        responses.append(result as! Bool)
    }
    precondition(responses == [status == .authorized])
}

for granted in [true, false] {
    CNContactStore.granted = granted
    CNContactStore.error = nil
    var responses = [Bool]()
    plugin.handle(FlutterMethodCall(method: "requestPermission")) { result in
        responses.append(result as! Bool)
    }
    precondition(responses == [granted])
}

CNContactStore.error = NSError(domain: "contacts-test", code: 1)
CNContactStore.granted = true
var responses = [Bool]()
plugin.handle(FlutterMethodCall(method: "requestPermission")) { result in
    responses.append(result as! Bool)
}
precondition(responses == [false])
precondition(CNContactStore.requests == 3)

var unsupported = false
plugin.handle(FlutterMethodCall(method: "unknown")) { result in
    unsupported = (result as AnyObject) === FlutterMethodNotImplemented
}
precondition(unsupported)
print("Swift native permission checks passed")
