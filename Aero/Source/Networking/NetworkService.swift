//
//  NetworkService.swift
//  MyGeneRank
//
//  Created by Brian Schrader on 5/24/16.
//  Copyright © 2016 Scripps Translational Science Institute, Inc. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import ObjectMapper


public class NetworkServiceManager {    
    public static var sharedManager = NetworkService()
}


public enum NetworkServiceNotification: String {
    case isReady = "NetworkService.IsReadyNotification"
    case isUnreachable = "NetworkService.NetworkIsUnreachableNotification"
}

public enum NetworkServiceError: String {
    case InitialEndpointFetchFailure = "Failed to parse intial endpoints."
}


/*!
 * A service that abstracts the underlying network calls and stores data
 * to the data store, or returns them in the completion handler.
 */
public class NetworkService {
    
    var endpoints: [String: String]?
    
    var _ready: Bool = false
    public var ready: Bool {
        get {
            return _ready
        }
        set {
            // Ensure that redundant notifications are not sent.
            //            guard _ready != newValue else { return }
            _ready = newValue
            if _ready {
                sendReadyNotification()
            }
        }
    }
    
    var _unreachable: Bool = false
    public var isUnreachable: Bool {
        get {
            return _unreachable
        }
        set {
            // Ensure that redundant notifications are not sent.
            guard _unreachable != newValue else { return }
            _unreachable = newValue
            if _unreachable {
                sendUnreachableNotification()
            }
        }
    }
    
    public func configure(_ apiRootUrl: String) {
        let request = Alamofire.request(apiRootUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
        request.responseJSON { (response: DataResponse) in
            guard response.result.error == nil else {
                self.isUnreachable = true
                self.ready = false
                return
            }
            guard let endpoints = response.result.value as? [String: String] else {
                print(NetworkServiceError.InitialEndpointFetchFailure.rawValue)
                return
            }
            
            self.endpoints = endpoints
            self.ready = true
            self.isUnreachable = false
        }
    }
    
    func sendReadyNotification() {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: NetworkServiceNotification.isReady.rawValue), object: self)
    }
    
    func sendUnreachableNotification() {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: NetworkServiceNotification.isUnreachable.rawValue), object: self)
    }
    
    // MARK: Private Methods
    
    func serializeObjectParams<T:RemoteResultProtocol>(_ object: T, withParameters params: [String: AnyObject]?) -> [String: AnyObject]? {
        var parameters = params != nil ? params : [:]
        parameters!.unionInPlace(object.toJSON() as Dictionary<String, AnyObject>)
        return parameters
    }
    
    /*!
     * Fetch a results list from the given API endpoint.
     */
    public func getResults<T: RemoteResultProtocol>(_ url: String, params: [String: AnyObject]?, headers: [String: String]?,
                    completionHandler: @escaping (_ results: [T]?) -> ()) {
        self.request(.get, url, parameters: params, encoding: URLEncoding.default, headers: headers) { request in
            request.responseArray(queue: DispatchQueue.main, keyPath: "results", context: nil) { (results: DataResponse<[T]>) in
                guard results.result.error == nil else {
                    self.isUnreachable = true
                    completionHandler(nil); return
                }
                self.isUnreachable = false
                completionHandler(results.result.value)
            }
        }
    }
    
    /*!
     * Fetch a single item from the given API endpoint.
     */
    public func getObject<T: RemoteResultProtocol>(_ url: String, params: [String: AnyObject]?, headers: [String: String]?,
                   completionHandler: @escaping (_ result: T?) -> ()) {
        self.request(.get, url, parameters: params, encoding: URLEncoding.default, headers: headers) { request in
            request.responseObject { (result: DataResponse<T>) in
                completionHandler(result.result.value)
            }
        }
    }
    
    /*!
     * Post a given item to the given URL.
     */
    public func postObject<T: RemoteResultProtocol>(_ object: T, url: String, params: [String: AnyObject]?, headers: [String: String]?,
                    completionHandler: @escaping (_ result: T?) -> ()) {
        self.request(.post, url, parameters: self.serializeObjectParams(object, withParameters: params), encoding: JSONEncoding.default, headers: headers) { request in
            request.responseObject { (result: DataResponse<T>) in
                completionHandler(result.result.value)
            }
        }
    }
    
    /*!
     * Update a given item at the given API endpoint.
     */
    func putObject<T: RemoteResultProtocol>(_ object: T, url: String, params: [String: AnyObject]?,
                   headers: [String: String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        self.request(.put, url, parameters: self.serializeObjectParams(object, withParameters: params), encoding: JSONEncoding.default, headers: headers) { request in
            request.responseJSON(completionHandler: completionHandler)
        }
    }
    
    
    /*!
     * Delete a given item from the given API endpoint.
     */
    public func deleteObject<T: RemoteResultProtocol>(_ object: T, url: String, params: [String: AnyObject]?,
                      headers: [String: String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        self.request(.delete, url, parameters: self.serializeObjectParams(object, withParameters: params), encoding: JSONEncoding.default, headers: headers) { request in
            request.responseJSON(completionHandler: completionHandler)
        }
    }
    
    
    public func uploadFile<T: RemoteResultProtocol>(_ filename: String, name: String, data: Data, with object: T, url: String,
                    params: [String: AnyObject]?, headers: [String: String]?, completionHandler: @escaping (T?) -> ()) {
        guard let params = self.serializeObjectParams(object, withParameters: params) as? [String: String] else {
            assertionFailure("Parameters are not coerced to strings"); return
        }
        do {
            let (request, data) = try uploadRequestWith(url: url, headers: headers, parameters: params, filename: filename, name: name,
                                                        contentType: "application/octet-stream", data: data)
            print(request.debugDescription)
            Alamofire.upload(data, with: request).responseObject { (result: DataResponse<T>) in
                completionHandler(result.result.value)
            }
        } catch {
            completionHandler(nil)
        }
    }
    
    
    /*!
     * The internal request wrapper function.
     */
    public func request(_ method: Alamofire.HTTPMethod, _ url: String, parameters: [String: AnyObject]?, encoding: ParameterEncoding, headers: [String: String]?, callback: @escaping (_ request: DataRequest) -> ()) {
        let request = Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        callback(request)
    }
    
    // Private Methods
    
    /**
     * A file upload request generator function that adds parameters to a file upload request body.
     * via: http://stackoverflow.com/questions/26121827/uploading-file-with-parameters-using-alamofire
     * Slightly modified from original code.
     */
    internal func uploadRequestWith(url: String, headers: [String: String]?, parameters: [String: String],
                                    filename: String, name: String, contentType: String, data: Data) throws -> (URLRequest, Data) {
        // create url request to send
        var mutableURLRequest = URLRequest(url: URL(string: url)!)
        mutableURLRequest.httpMethod = Alamofire.HTTPMethod.post.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary=\(boundaryConstant)"
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Add Headers
        headers?.forEach { (key, value) in
            mutableURLRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // create upload data to send
        let boundary = "\r\n--\(boundaryConstant)\r\n"
        
        // add parameters
        var params = parameters.map { (key, value) in
            return boundary + "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)"
            }.joined()
        
        // add file
        params += boundary
        params += "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n"
        params += "Content-Type: \(contentType)\r\n\r\n"
        
        // Convert to data
        var uploadData = params.data(using: String.Encoding.utf8)!
        uploadData.append(data)
        uploadData.append(boundary.data(using: String.Encoding.utf8)!)
        
        // return URLRequestConvertible and NSData
        let request = try URLEncoding().encode(mutableURLRequest, with: parameters)
        return (request, uploadData)
    }
}
