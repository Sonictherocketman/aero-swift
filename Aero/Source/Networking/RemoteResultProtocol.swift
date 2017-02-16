// RemoteResultProtocol
// A protcol that provides convenience functionality to models that 
// map directly to RESTful endpoints.
//
// author: Brian Schrader

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import CoreData


@objc(RemoteResultObjCProtocol)
protocol RemoteResultObjCProtocol {
    static var serializedIdentifier: String { get set }
    var url: String? { get set }
}

/**
 * A protocol that provides convinience methods for mapping, querying, and persisting
 * data to a remote REST API using the NetworkService.
 */
protocol RemoteResultProtocol: StaticMappable, RemoteResultObjCProtocol {
    //Just combines the two protocols.
}

extension RemoteResultProtocol {
    
    /*!
     * Fetch a single object from the remote API.
     */
    static func getSingle<T: RemoteResultProtocol>(_ headers: Dictionary<String, String>?, completionHandler: @escaping (_: T?) -> ()) {
        guard let endpoint = NetworkServiceManager.sharedManager.endpoints?[serializedIdentifier] else {
            completionHandler(nil); return
        }
        NetworkServiceManager.sharedManager.getObject(endpoint, params: nil, headers: headers, completionHandler: completionHandler)
    }
    
    /*!
     * Fetch a result set from the remote API.
     */
    static func getResultSet<T: RemoteResultProtocol>(_ headers: Dictionary<String, String>?, completionHandler: @escaping (_: [T]?) -> ()) {
        guard let endpoint = NetworkServiceManager.sharedManager.endpoints?[serializedIdentifier] else {
            completionHandler(nil); return
        }
        NetworkServiceManager.sharedManager.getResults(endpoint , params: nil, headers: headers, completionHandler: completionHandler)
    }
    
    /*!
     * Search for a result set from the remote API.
     */
    static func search<T: RemoteResultProtocol>(_ params: Dictionary<String, String>?, headers: Dictionary<String, String>?,
                       completionHandler: @escaping (_: [T]?) -> ()) {
        guard let endpoint = NetworkServiceManager.sharedManager.endpoints?[serializedIdentifier] else {
            completionHandler(nil); return
        }
        NetworkServiceManager.sharedManager.getResults(endpoint, params: params as [String : AnyObject]?, headers: headers, completionHandler: completionHandler)
    }
    
    /*! 
     * Post a new object, with a url based on it's type, to the remote API.
     */
    static func insert<T: RemoteResultProtocol>(_ object: T, params: [String: AnyObject]?, headers: [String: String]?, completionHandler: @escaping (_ result: T?) -> ()) {
        guard let endpoint = NetworkServiceManager.sharedManager.endpoints?[serializedIdentifier] else {
            completionHandler(nil); return
        }
        NetworkServiceManager.sharedManager.postObject(object, url: endpoint, params: params, headers: headers,
            completionHandler: completionHandler)
    }
    
    static func upload<T: RemoteResultProtocol>(_ object: T, filedata: Data, filename: String, name: String, params: [String: AnyObject]?,
                       headers: [String: String]?, completionHandler: @escaping (_ result: T?) -> ()) {
        guard let endpoint = NetworkServiceManager.sharedManager.endpoints?[serializedIdentifier] else {
            completionHandler(nil); return
        }
        NetworkServiceManager.sharedManager.uploadFile(filename, name: name, data: filedata, with: object, url: endpoint, params: params,
                                                       headers: headers, completionHandler: completionHandler)
    }
    
    /*!
     * Given a model, persist it to the remote API.
     */
    
    func save(_ headers: Dictionary<String, String>?, completionHandler: @escaping (_ response: DataResponse<Any>) -> ()) {
        NetworkServiceManager.sharedManager.putObject(self, url: self.url!, params: nil, headers: headers, completionHandler: completionHandler)
    }

    func save() {
        NetworkServiceManager.sharedManager.putObject(self, url: self.url!, params: nil, headers: nil,
                                                      completionHandler: { _ in })
    }
    
    /*!
     * Deletes a given model from the remote API.
     */
    func delete(_ headers: Dictionary<String, String>?, completionHandler: @escaping (_ response: DataResponse<Any>) -> ()) {
        NetworkServiceManager.sharedManager.deleteObject(self, url: self.url!, params: nil, headers: headers, completionHandler: completionHandler)
    }
}


//class InconsistentArrayElementsError : Error {
//    var message: String?
//    
//    convenience init(message: String?) {
//        self.init()
//        self.message = message
//    }
//}
//
//extension Array where Iterator.Element : RemoteResultProtocol {
//    
//    /**
//     * Batch save a group of results to avoid excessive network traffic.
//     */
//    func saveAll(completionHandler: @escaping (_ data: RemoteResultProtocol?) -> ()) throws {
//        let type = type(of: first)
//        let isSameTypes = self.filter { type(of: $0) == type }.all()
//        guard isSameTypes else {
//            throw InconsistentArrayElementsError(message: "Not all array elements are of the same type. Expected type: \(type)")
//        }
//        
//        guard let element = first as? RemoteResultProtocol, let url = type.url else {
//            completionHandler(nil); return
//        }
//        
//    }
//}

/**
 * A protocol that combines the features of RemoteResultProtocol and adds convinience
 * methods for NSManagedObject subclasses.
 */
protocol ManagedRemoteObjectProtocol: RemoteResultProtocol, NSFetchRequestResult {
    static var defaultSortDescriptor: String? { get }
}

extension ManagedRemoteObjectProtocol {
    
    static func updateStoredData(_ completionHandler: @escaping ()->()) {
        // Search for and remove existing entries.
        let request: NSFetchRequest<Self> = NSFetchRequest(entityName: NSStringFromClass(Self.self))
        
        if let sort = defaultSortDescriptor {
            request.sortDescriptors = [NSSortDescriptor(key: sort, ascending: true)]
        }
        var objects: [Self] = []
        do {
            objects = try ContextManager.sharedManagedObjectContext.fetch(request)
        } catch {
            fatalError("Could not fetch objects.")
        }

        search(nil, headers: nil) { (results: [Self]?) in
            guard let _ = results else { completionHandler(); return }
            
            // Delete the old ones.
            for obj in objects {
                ContextManager.sharedManagedObjectContext.delete(obj as! NSManagedObject)
            }

            // Persist new records.
            do {
                try ContextManager.sharedManagedObjectContext.save()
            } catch {
                fatalError("Could not save new objects.")
            }
            completionHandler()
        }
    }
    
    static func fetchStoredObjects() -> [Self] {
        var objects: [Self] = []
        with(CoreDataContext()) { (context: CoreDataContext) in
            let request: NSFetchRequest<Self> = NSFetchRequest(entityName: NSStringFromClass(Self.self))
            if let sort = defaultSortDescriptor {
                request.sortDescriptors = [NSSortDescriptor(key: sort, ascending: true)]
            }
            do {
                objects = try context.coreDataContext.fetch(request)
            } catch {
                fatalError("Could not fetch activities.")
            }
        }
        return objects
    }
    
}
