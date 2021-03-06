// Context Manager
// A misleadingly named class that handles creating Object Contexts for Core Data.
// TODO: Rename. The name conflicts with ContextManagers and the `with` statement.
//
// author: Brian Schrader

import CoreData

public class ContextManager {
    
    public static var sharedManagedObjectContext: NSManagedObjectContext = ContextManager.getManagedObjectContext(type: .mainQueueConcurrencyType)
    
    public init() {
        ContextManager.sharedManagedObjectContext = ContextManager.getManagedObjectContext(type: .mainQueueConcurrencyType)
    }
    
    public static func getManagedObjectContext(type: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "Model", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let context = NSManagedObjectContext(concurrencyType: type)
        context.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.appendingPathComponent("Model")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
                ])
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        return context
    }
    
    /**
     * Delete the current context, and create a new global store.
     */
    public static func flushContext() {
        let context = ContextManager.sharedManagedObjectContext
        for store in (context.persistentStoreCoordinator?.persistentStores)! {
            do {
                try context.persistentStoreCoordinator?.remove(store)
                try FileManager.default.removeItem(atPath: (store.url?.path)!)
            } catch {
            }
        }
        ContextManager.sharedManagedObjectContext = ContextManager.getManagedObjectContext(type: .mainQueueConcurrencyType)
    }
}
