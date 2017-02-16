//
//  CoreDataContextManager.swift
//  Aero-Swift
//
//  Created by Brian Schrader on 2/15/17.
//
//

import Foundation
import CoreData


struct CoreDataContext: Context {
    var coreDataContext: NSManagedObjectContext
    
    init() {
        coreDataContext = ContextManager.sharedManagedObjectContext
    }
    
    init(newContext: Bool) {
        if newContext {
            coreDataContext = ContextManager.getManagedObjectContext(type: .mainQueueConcurrencyType)
        } else {
            coreDataContext = ContextManager.sharedManagedObjectContext
        }
    }
    
    func enter() {
        //Do Nothing
    }
    
    func exit(_ error: Error?) {
        //        if coreDataContext.hasChanges {
        //            do {
        //                try coreDataContext.save()
        //            } catch {
        //                fatalError("unable to save changes \(error)")
        //            }
        //        }
    }
}