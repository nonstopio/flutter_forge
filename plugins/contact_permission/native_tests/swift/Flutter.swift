@_exported import Foundation

public typealias FlutterResult = (Any?) -> Void
public let FlutterMethodNotImplemented = NSObject()
public protocol FlutterPluginRegistrar {
    func messenger() -> NSObject
    func addMethodCallDelegate(_ instance: FlutterPlugin, channel: FlutterMethodChannel)
}
public protocol FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar)
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
}
public final class FlutterMethodChannel {
    public let name: String
    public let binaryMessenger: NSObject
    public init(name: String, binaryMessenger: NSObject) {
        self.name = name
        self.binaryMessenger = binaryMessenger
    }
}
public final class FlutterMethodCall {
    public let method: String
    public init(method: String) { self.method = method }
}
