import Foundation

// credit: https://stackoverflow.com/users/1155354/kosuke-ogawa

class KeyChain {

	static var highscore: Int {
		get {
			if let receivedString = KeyChain.load(key: "highscore") {
				return Int(receivedString) ?? 0
			} else {
				return 0
			}
		} set {
			KeyChain.save(key: "highscore", value: String(newValue))
		}
	}
	
	static var username: String? {
		get {
			if let receivedString = KeyChain.load(key: "username") {
				return receivedString
			} else {
				return nil
			}
		} set {
			KeyChain.save(key: "username", value: newValue!)
		}
	}
	
	class func delete(key: String) {
		let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key]

        SecItemDelete(query as CFDictionary)
	}

    class func save(key: String, value: String) -> OSStatus {
        let data = value.data(using: .utf8)
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: String) -> String? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
			return String(data: dataTypeRef as! Data, encoding: .utf8)
        } else {
            return nil
        }
    }

    class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}
