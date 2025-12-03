//
//  KeychainHelper.swift
//  QuestionsApp
//
//  Created by William Cather on 12/3/25.
//

import Foundation

enum KeychainKey: String {
    case username
    case password
}

class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    func save(_ value: String?, for key: KeychainKey) {
        guard let value = value, let data = value.data(using: .utf8) else {
            // Delete if nil
            delete(for: key)
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary) // overwrite if exists
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func get(_ key: KeychainKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data, let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
    
    func delete(for key: KeychainKey) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }
}
