//
//  OAuthNetworkService.swift
//
//  Created by Brian Schrader on 7/20/16.
//

import Foundation
import Alamofire


/*!
 * OAuth Extension Methods
 */

public enum OAuthNetworkServiceError: String {
    case StoredTokenPersitenceError = "Stored Token Was Unable to be Saved."
    case StoredTokenDeletionError = "Stored Token Was Unable to be Deleted."
    case MissingTokenError = "OAuth Token did not exist at time of use."
    case MalformedTokenError = "Token is malformed."
    case InvalidResponseError = "Invalid Response"
    case InvalidSettingsError = "The provided application settings are invalid."
}

public enum OAuthNetworkServiceNotification: String {
    /**
     * This notification is fired whenever the Service has detected that a user, which was
     * logged in, is no longer.
     */
    case HasLoggedOutNotification = "You have been logged out."
    case HasRegisteredNotification = "Registration successful."
    case HasLoggedInNotification = "Login successful."
}

public class OAuthNetworkService: NetworkService {
    
    var oauthCredentials: [String: String] = [:]
    
    /**
     * The token is stored in the user's keychain as an encrypted JSON string.
     */
    var storedToken = KeychainBackedToken()
    
    
    // MARK: Public Methods
    
    func configure(_ apiRootUrl: String, oauthCredentials: [String: String]) {
        self.oauthCredentials = oauthCredentials
        super.configure(apiRootUrl)
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
                print(response.response!)
                completionHandler(false, OAuthNetworkServiceError.InvalidResponseError.rawValue)
                return
            }
            guard response.response?.statusCode == 201 else {
                completionHandler(false, token["message"] as? String); return }
            
            
            self.sendRegistrationNotification()
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
        getInitialToken(oauthCredentials , username: username, password: password) { (success, message) in
            self.sendLoginNotification()
            return completionHandler(success, message)
        }
    }
    
    override public func uploadFile<T: RemoteResultProtocol>(_ filename: String, name: String, data: Data, with object: T, url: String, params: [String: AnyObject]?,
                             headers: [String: String]?, completionHandler: @escaping (T?) -> ()) {
        guard let params = self.serializeObjectParams(object, withParameters: params) as? [String: String] else {
            assertionFailure("Parameters are not coerced to strings"); return
        }
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
    
    public override func request(_ method: Alamofire.HTTPMethod, _ url: String, parameters: [String: AnyObject]?, encoding: ParameterEncoding, headers: [String: String]?, callback: @escaping (_ request: DataRequest) -> ()) {
        let headers = self.getOauthHeaders(headers)
        super.request(method, url, parameters: parameters, encoding: encoding, headers: headers, callback: callback)
    }
    
    /**
     * Before calling the request, check if the current OAuth Token is valid, and if not
     * renew it.
     */
    func oauthTokenDance(_ request: @escaping ()->()) {
        // Pass to the request if the token is missing.
        guard let token = storedToken.value else { request(); return }
        guard let refreshToken = token["refresh_token"] else {
            sendLogoutNotificationWithMessage(OAuthNetworkServiceError.MalformedTokenError.rawValue); return
        }
        guard let uri = oauthCredentials["token_uri"] else {
            sendLogoutNotificationWithMessage(OAuthNetworkServiceError.InvalidSettingsError.rawValue); return
        }
        
        let params = [
            "grant_type" : "refresh_token",
            "refresh_token" : refreshToken,
            "client_id": oauthCredentials["client_id"]!,
            "client_secret": ""
            ] as [String : Any]
        let headers: [String: String] = [:]
        
        let oauthRequest = Alamofire.request(uri, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers)
        oauthRequest.responseJSON { response in
            let (success, _) = self.handlePersistingToken(response)
            guard success == true else {
                self.sendLogoutNotificationWithMessage(OAuthNetworkServiceError.StoredTokenPersitenceError.rawValue); return
            }
            request()
        }
    }
    
    func flushStoredToken() {
        guard let token = storedToken.value?["access_token"] else {
            // Just delete the token and exit.
            storedToken.value = nil
            return
        }
        
        let settings = self.oauthCredentials
        
        let url = settings["revoke_uri"]!
        let params = [
            "client_id": settings["client_id"]!,
            "token": token
            ] as [String: AnyObject]
        
        self.request(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil) { request in
            request.response() { response in
                if response.response?.statusCode != 200 {
                    NSLog("ERROR REVOKING TOKEN")
                }
                self.storedToken.value = nil
            }
        }
    }
    
    // MARK: Private Methods
    
    fileprivate func getOauthHeaders(_ headers: [String: String]?) -> [String: String] {
        guard let token = storedToken.value else {
            let notifications = NotificationCenter.default
            let notification = Notification.Name(rawValue: OAuthNetworkServiceError.MissingTokenError.rawValue)
            notifications.post(name: notification, object: self)
            return [:]
        }
        
        var hdrs = headers ?? [:]
        if let accessToken = token["access_token"] as? String {
            hdrs["Authorization"] = "Bearer \(accessToken)"
        }
        return hdrs
    }
    
    fileprivate func getInitialToken(_ oauthCrendentials: [String: String], username: String, password: String, completionHandler: @escaping (_ success: Bool, _ message: String?)->()?) {
        guard let grantType = oauthCredentials["grant_type"] else {
            sendLogoutNotificationWithMessage(OAuthNetworkServiceError.InvalidSettingsError.rawValue); return
        }
        guard let uri = oauthCredentials["token_uri"] else {
            sendLogoutNotificationWithMessage(OAuthNetworkServiceError.InvalidSettingsError.rawValue); return
        }
        
        let settings = self.oauthCredentials
        let params: [String: String] = [
            "grant_type": grantType,
            "username": username,
            "password": password,
            "client_id": settings["client_id"]!
        ]
        let oauthRequest = Alamofire.request(uri, method: .post , parameters: params, encoding: URLEncoding.default, headers: nil)
        oauthRequest.responseJSON { response in
            let (success, message) = self.handlePersistingToken(response)
            completionHandler(success, message)
        }
    }
    
    /**
     * Given a response, check if the token is valid, and if so store it.
     */
    fileprivate func handlePersistingToken(_ response: DataResponse<Any>) -> (Bool, String?) {
        guard response.response != nil else {
            // The server didn't respond. Do not delete the token.
            return (true, nil)
        }
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
    
    fileprivate func sendRegistrationNotification() {
        let notifications = NotificationCenter.default
        notifications.post(name: Notification.Name(rawValue: OAuthNetworkServiceNotification.HasRegisteredNotification.rawValue), object: self)
    }
    
    fileprivate func sendLoginNotification() {
        let notifications = NotificationCenter.default
        notifications.post(name: Notification.Name(rawValue: OAuthNetworkServiceNotification.HasLoggedInNotification.rawValue), object: self)
    }
}
