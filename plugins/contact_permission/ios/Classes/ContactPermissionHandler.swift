import Contacts

class ContactPermissionHandler {
    static func isPermissionGranted() -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return status == .authorized
    }

    static func requestPermission(completion: @escaping (_ granted: Bool) -> Void) {
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                completion(false)
            } else {
                completion(granted)
            }
        }
    }
}
