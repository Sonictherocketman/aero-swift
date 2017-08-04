// Core Data Contexts
//
// author: Brian Schrader

import Foundation
import CoreData


public struct CoreDataContext: Context {
    public var coreDataContext: NSManagedObjectContext
    
    public init() {
        coreDataContext = ContextManager.sharedManagedObjectContext
    }
    
    public init(newContext: Bool) {
        if newContext {
            coreDataContext = ContextManager.getManagedObjectContext(type: .mainQueueConcurrencyType)
        } else {
            coreDataContext = ContextManager.sharedManagedObjectContext
        }
    }
    
    public func enter() {
        //Do Nothing
    }
    
    public func exit(_ error: Error?) {
        //        if coreDataContext.hasChanges {
        //            do {
        //                try coreDataContext.save()
        //            } catch {
        //                fatalError("unable to save changes \(error)")
        //            }
        //        }
    }
}
