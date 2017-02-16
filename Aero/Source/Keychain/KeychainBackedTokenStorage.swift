// KeychainBackedToken
// A token that uses Keychain as it's backing store. Useful 
// for storing encrypted OAuth Tokens.
//
// author: Brian Schrader

import Foundation
import Locksmith


enum KeyChainIdentifier: String {
    case UserAccount = "OAuthNetworingService.User"
}

/**
 * A simple class that contains a value dict that is persisted to the keychain on change.
 */
class KeychainBackedToken {
    
    var value: [String: Any]? {
        get {
            if let values = Locksmith.loadDataForUserAccount(userAccount: KeyChainIdentifier.UserAccount.rawValue) {
                return values as [String : Any]?
            }
            return nil
        }
        set {
            if let value = newValue {
                do {
                    try Locksmith.updateData(data: value, forUserAccount: KeyChainIdentifier.UserAccount.rawValue)
                } catch {
                    assertionFailure(OAuthNetworkServiceError.StoredTokenPersitenceError.rawValue)
                }
            } else {
                do {
                    try Locksmith.deleteDataForUserAccount(userAccount: KeyChainIdentifier.UserAccount.rawValue)
                } catch {
                    assertionFailure(OAuthNetworkServiceError.StoredTokenDeletionError.rawValue)
                }
            }
        }
    }
    
    var isValid: Bool {
        get {
            // Assure that a token exists.
            guard let token = value else { return false }
            // Check the validity of the token.
            guard let expiresIn = token["expires_in"] as? Int else { return false }
            // Check if there's a valid recieved time.
            guard let recievedAt = token["recieved_at"] as? Int else { return false }
            // Check if the token value exists. 
            guard let _ = token["refresh_token"] else { return false }
            
            let currentTime = Int(Date.timeIntervalSinceReferenceDate)
            return recievedAt + expiresIn > currentTime
        }
    }
    
    var isMalformed: Bool {
        get { return KeychainBackedToken.isMalformed(self.value) }
    }

    static func isMalformed(_ token: [String: Any]?) -> Bool {
        guard let value = token else { return false }
        return !value.keys.contains("access_token")
    }


}
