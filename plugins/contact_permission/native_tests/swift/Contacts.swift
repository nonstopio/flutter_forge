import Foundation

public enum CNEntityType { case contacts }
public enum CNAuthorizationStatus { case notDetermined, restricted, denied, authorized, limited }

/// Test double for the SDK boundary. Production sources are compiled unchanged.
public final class CNContactStore {
    public static var status: CNAuthorizationStatus = .notDetermined
    public static var granted = false
    public static var error: Error?
    public static var requests = 0
    public init() {}
    public static func authorizationStatus(for entity: CNEntityType) -> CNAuthorizationStatus {
        precondition(entity == .contacts)
        return status
    }
    public func requestAccess(for entity: CNEntityType, completionHandler: (Bool, Error?) -> Void) {
        precondition(entity == .contacts)
        Self.requests += 1
        completionHandler(Self.granted, Self.error)
    }
}
