//
//  Keychain.swift
//  iOSConcepts
//
//  Created by Sateesh Yegireddi on 24/08/19.
//  Copyright © 2019 Company. All rights reserved.
//

import Foundation

private enum KeychainError: Error {
    case noKeychainData
    case unexpectedKeychainData
    case unexpectedItemData
    case unhandledError(status: OSStatus)
}

final class Keychain: NSObject {
    
    // MARK: - Variables -
    
    /// ServiceName is used for the kSecAttrService property to uniquely identify this keychain accessor. If no service name is specified, Keychain will default to using the bundleIdentifier.
    private (set) public var serviceName: String
    
    /// AccessGroup is used for the kSecAttrAccessGroup property to identify which Keychain Access Group this entry belongs to. This allows you to use the Keychain with shared keychain access between different applications.
    private (set) public var accessGroup: String?
    
    /// Default Keychain access
    public static let standard = Keychain()
    private static let defaultServiceName: String = {
        return Bundle.main.bundleIdentifier ?? bundleIdentifier
    }()
    
    private convenience override init() {
        self.init(serviceName: Keychain.defaultServiceName)
    }
    
    // MARK: - Init -
    
    /// Create a custom instance of Keychain with a custom Service Name and optional custom access group.
    ///
    /// - parameter serviceName: The ServiceName for this instance. Used to uniquely identify all keys stored using this keychain wrapper instance.
    /// - parameter accessGroup: Optional unique AccessGroup for this instance. Use a matching AccessGroup between applications to allow shared keychain access.
    public init(serviceName: String, accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }
    
    // MARK: - Keychain access query -
    
    /// Create a query with essentials for a given key.
    ///
    /// - parameter key: Key to generate a query.
    private func keychainQuery(forKey key: String) -> [String: Any] {
        //  Setup default access as generic password (rather than a certificate, internet password, etc)
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        //  Uniquely identify this keychain accessor
        query[kSecAttrService as String] = serviceName as AnyObject?
        //  Set the keychain access group if defined
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        //  Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier: Data? = key.data(using: String.Encoding.utf8)
        query[kSecAttrGeneric as String] = encodedIdentifier as AnyObject?
        query[kSecAttrAccount as String] = encodedIdentifier as AnyObject?
        // Return Keychain Query
        return query
    }
    
    //MARK: - Clear -
    
    private func clearKeyChain() throws {
        do {
            try deleteData(for: .user)
            try deleteData(for: .APIToken)
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    /// Remove all keychain data added throughout the app. This will only delete items matching the currnt ServiceName and AccessGroup if one is set.
    private func wipeoutKeyChain() throws {
        //  Setup dictionary to access keychain and specify we are using a generic password (rather than a certificate, internet password, etc)
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        //  Uniquely identify this keychain accessor
        query[kSecAttrService as String] = serviceName as AnyObject?
        //  Set the keychain access group if defined
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        //  Add a the new item to the keychain.
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        //  Throw an error if an unexpected status was returned.
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
    }
    
    //MARK: - Manipulation of Data -
    
    private func saveData(_ data: Data, for key: Key) throws {
        do {
            //  Check for an existing item in the keychain.
            try _ = getData(for: key)
            //  Update the existing item with the new password.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = data as AnyObject?
            // Build a query to find the item that matches the service, account and access group.
            let query = self.keychainQuery(forKey: key.rawValue)
            //  Try to update the existing keychain item that matches the query.
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            //  Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
        catch KeychainError.noKeychainData {
            // No password was found in the keychain. Create a dictionary to save as a new keychain item.
            var newItem = self.keychainQuery(forKey: key.rawValue)
            newItem[kSecValueData as String] = data as AnyObject?
            //  Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            //  Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    private func getData(for key: Key) throws -> Data {
        // Build a query to find the item that matches the service, account and access group.
        var query = self.keychainQuery(forKey: key.rawValue)
        //  Limit search results to one
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        //  Specify we want SecAttrAccessible returned
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        //  Specify we want Data/CFData returned
        query[kSecReturnData as String] = kCFBooleanTrue
        //  Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        //  Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noKeychainData }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        //  Parse the token string from the query result.
        guard let existingItem = queryResult as? [String : AnyObject],
            let data = existingItem[kSecValueData as String] as? Data
            else {
                throw KeychainError.unexpectedKeychainData
        }
        return data
    }
    
    private func deleteData(for key: Key) throws {
        // Build a query to find the item that matches the service, account and access group.
        let query = self.keychainQuery(forKey: key.rawValue)
        //  Delete the existing item from the keychain.
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        //  Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

// MARK: - Keychain Configuration -

private struct KeychainConfiguration {
    static let serviceName = bundleIdentifier
    /*
     Specifying an access group to use with `KeychainPasswordItem` instances
     will create items shared accross both apps.
     
     For information on App ID prefixes, see:
     https:// developer.apple.com/library/ios/documentation/General/Conceptual/DevPedia-CocoaCore/AppID.html
     and:
     https:// developer.apple.com/library/ios/technotes/tn2311/_index.html
     */
    //     static let accessGroup = "[YOUR APP ID PREFIX].com.example.apple-samplecode.GenericKeychainShared"
    
    /*
     Not specifying an access group to use with `KeychainPasswordItem` instances
     will create items specific to each app.
     */
    static let accessGroup: String? = Bundle.main.bundleIdentifier ?? bundleIdentifier
}

//MARK: - Custom Functionality -

private let bundleIdentifier = "com.company.target"

private enum Key: String {
    case APIToken
    case user
}

extension Keychain {
    func saveAPIToken(_ token: String) {
        do {
            if let data = token.data(using: .utf8) {
                try saveData(data, for: .APIToken)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func getAPIToken() -> String {
        do {
            let data = try getData(for: .APIToken)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func saveUser(_ user: NSObject) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: true)
            try saveData(data, for: .user)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func getUser() -> NSObject {
        do {
            let data = try getData(for: .user)
            let user = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! NSObject
            return user
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

//Write this in appDelegate
//Initialise Keychain access instance for only once across the application.
///Note: If the keychain service will not work if we are initialising it multiple times, so make sure to use singleton instance whenever we are using it anywhere in the application...
//let _ = Keychain(serviceName: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup)


//Keychain.standard.saveAPIToken("DJSLFJSKLFJS-SFKJSDLDKSJFL-SFDJSLFJDSLKFS")
//Keychain.standard.getAPIToken()

