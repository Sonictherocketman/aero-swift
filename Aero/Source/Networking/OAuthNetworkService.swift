// OAuthNetworking Service
// A NetworkService subclass that provides automatic handling of OAuth tokens.
//
// author: Brian Schrader

import Foundation
import Alamofire


/*!
 * OAuth Extension Methods
 */

enum OAuthNetworkServiceError: String {
    case StoredTokenPersitenceError = "Stored Token Was Unable to be Saved."
    case StoredTokenDeletionError = "Stored Token Was Unable to be Deleted."
    case MissingTokenError = "OAuth Token did not exist at time of use."
    case MalformedTokenError = "Token is malformed."
    case InvalidResponseError = "Invalid Response"
    case InvalidSettingsError = "The provided application settings are invalid."
}

enum OAuthNetworkServiceNotification: String {
    /**
     * This notification is fired whenever the Service has detected that a user, which was
     * logged in, is no longer.
     */
    case HasLoggedOutNotification = "You have been logged out."
}

class OAuthNetworkService: NetworkService {
    
    var oauthCredentials: [String: String] = [:]
    
    /**
     * The token is stored in the user's keychain as an encrypted JSON string.
     */
    var storedToken = KeychainBackedToken()
    
    
    // MARK: Public Methods
    
    func configure(_ apiRootUrl: String, oauthCredentials: [String: String]) {
        self.oauthCredentials = oauthCredentials
        self.configure(apiRootUrl)
    }
    
    func register(_ username: String, password: String, email: String, completionHandler: @escaping (_ success: Bool, _ message: String?) ->()) {
        let params: [String: String] = [
            "username": username,
            "password": password,
            "email": email,
            ]
        
        let oauthRequest = Alamofire.request(oauthCredentials["register_uri"]!, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
        oauthRequest.responseJSON { response in
            guard let token = response.result.value as? [String: AnyObject] else {
                completionHandler(false, OAuthNetworkServiceError.InvalidResponseError.rawValue)
                return
            }
            guard response.response?.statusCode == 201 else {
                completionHandler(false, token["message"] as? String); return }
            
            completionHandler(true, nil)
        }
    }
    
    func confirmRegistration(_ url: String, completionHandler: @escaping (_ success: Bool) -> ()) {
        let confirmRequest = Alamofire.request(url, method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil)
        confirmRequest.responseJSON { response in
            if response.response?.statusCode == 200 {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    func login(_ username: String, password: String, completionHandler: @escaping (_ success: Bool, _ message: String?)->()) {
        getInitialToken(oauthCredentials , username: username, password: password, completionHandler: completionHandler)
    }
    
    override func uploadFile<T: RemoteResultProtocol>(_ filename: String, name: String, data: Data, with object: T, url: String, params: [String: AnyObject]?,
                    headers: [String: String]?, completionHandler: @escaping (T?) -> ()) {
        guard let params = self.serializeObjectParams(object, withParameters: params) as? [String: String] else {
            assertionFailure("Parameters are not coerced to strings"); return
        }
        self.oauthTokenDance {
            do {
                let (request, data) = try self.uploadRequestWith(url: url, headers: self.getOauthHeaders(headers), parameters: params,
                                                                 filename: filename, name: name, contentType: "application/octet-stream",
                                                                 data: data)
                Alamofire.upload(data, with: request).responseObject { (result: DataResponse<T>) in
                    completionHandler(result.result.value)
                }
            } catch {
                completionHandler(nil)
            }
        }
    }
    
    public override func request(_ method: Alamofire.HTTPMethod, _ url: String, parameters: [String: AnyObject]?, encoding: ParameterEncoding, headers: [String: String]?, callback: @escaping (_ request: DataRequest) -> ()) {
        self.oauthTokenDance {
            let headers = self.getOauthHeaders(headers)
            super.request(method, url, parameters: parameters, encoding: encoding, headers: headers, callback: callback)
        }
    }
    
    func flushStoredToken() {
        storedToken.value = nil
    }
    
    // MARK: Private Methods
    
    fileprivate func getOauthHeaders(_ headers: [String: String]?) -> [String: String] {
        guard let token = storedToken.value else {
            sendLogoutNotificationWithMessage(OAuthNetworkServiceError.MissingTokenError.rawValue)
            return [:]
        }
        
        var hdrs = headers ?? [:]
        if let accessToken = token["access_token"] as? String {
            hdrs["Authorization"] = "Bearer \(accessToken)"
        }
        return hdrs
    }
    
    fileprivate func getLoginRefreshTokenHeaders(_ headers: [String: String]?) -> [String: String] {
        var hdrs = headers ?? [:]
        let token = "\(oauthCredentials["client_id"]!):\(oauthCredentials["client_secret"]!)"
            .data(using: String.Encoding.utf8)!
            .base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        hdrs["Authorization"] = "Basic \(token)"
        return hdrs
    }
    
    /**
     * Before calling the request, check if the current OAuth Token is valid, and if not
     * renew it.
     */
    fileprivate func oauthTokenDance(_ request: @escaping ()->()) {
        // Pass to the request if the token is valid.
        guard !storedToken.isValid else { request(); return }
        guard let token = storedToken.value else { request(); return }
        guard let refreshToken = token["refresh_token"] else {
            sendLogoutNotificationWithMessage(OAuthNetworkServiceError.MalformedTokenError.rawValue); return
        }
        guard let uri = oauthCredentials["token_uri"] else {
            sendLogoutNotificationWithMessage(OAuthNetworkServiceError.InvalidSettingsError.rawValue); return
        }

        let params = [ "grant_type" : "refresh_token", "refresh_token" : refreshToken ] as [String : Any]
        let headers = getLoginRefreshTokenHeaders(nil)
        
        let oauthRequest = Alamofire.request(uri, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers)
        oauthRequest.responseJSON { response in
            let (success, _) = self.handlePersistingToken(response)
            guard success == true else {
                self.sendLogoutNotificationWithMessage(OAuthNetworkServiceError.StoredTokenPersitenceError.rawValue); return
            }
            request()
        }
    }
    
    fileprivate func getInitialToken(_ oauthCrendentials: [String: String], username: String, password: String, completionHandler: @escaping (_ success: Bool, _ message: String?)->()?) {
        guard let grantType = oauthCredentials["grant_type"] else {
            sendLogoutNotificationWithMessage(OAuthNetworkServiceError.InvalidSettingsError.rawValue); return
        }
        guard let uri = oauthCredentials["token_uri"] else {
            sendLogoutNotificationWithMessage(OAuthNetworkServiceError.InvalidSettingsError.rawValue); return
        }
        
        let params: [String: String] = [ "grant_type": grantType, "username": username, "password": password ]
        let headers = getLoginRefreshTokenHeaders(nil)
        let oauthRequest = Alamofire.request(uri, method: .post , parameters: params, encoding: URLEncoding.default, headers: headers)
        oauthRequest.responseJSON { response in
            let (success, message) = self.handlePersistingToken(response)
            completionHandler(success, message)
        }
    }
    
    /**
     * Given a response, check if the token is valid, and if so store it.
     */ 
    fileprivate func handlePersistingToken(_ response: DataResponse<Any>) -> (Bool, String?) {
        guard response.response?.statusCode == 200 || response.response?.statusCode == 201 else {
            return (false, response.result.error?.localizedDescription)
        }
        guard var token = response.result.value as? [String: AnyObject] else {
            return (false, OAuthNetworkServiceError.InvalidResponseError.rawValue)
        }
        guard !KeychainBackedToken.isMalformed(token) else {
            return (false, OAuthNetworkServiceError.MalformedTokenError.rawValue)
        }
        
        token["recieved_at"] = Int(Date.timeIntervalSinceReferenceDate) as AnyObject?
        self.storedToken.value = token
        return (true, nil)
    }
    
    fileprivate func sendLogoutNotificationWithMessage(_ message: String) {
        print(message)
        
        let notifications = NotificationCenter.default
        notifications.post(name: Notification.Name(rawValue: OAuthNetworkServiceNotification.HasLoggedOutNotification.rawValue), object: self)
    }
}
