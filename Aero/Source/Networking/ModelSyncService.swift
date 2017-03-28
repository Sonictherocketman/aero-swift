// BackgroundModelUpdater
// A convenient protocol that provides an easy,
// thread-safe way of updating models via notifications.
//
// author: Brian Schrader

import Foundation

/**
 * Handles syncing model state to remote services.
 *
 * ModelSyncServices are used to perform updates and sync operations between locally
 * stored objects (or NSManagedObjects) to remote systems and receive updates.
 * 
 * The principle and only required method to implement is `sync` which performs the updates
 * and *should* alert the delegate of any updates or changes that should be made.
 */
public protocol ModelSyncService {
    
    var delegate: ModelSyncServiceDelegate? { get set }
    
    /**
     * This method should perform any updates or networked behavior.
     */
    func sync()
}

//extension ModelSyncService {
//    
//    func configure() {
//        let notifications = NotificationCenter.default
//        notifications.addObserver(forName: Notification.Name(rawValue: Notifications.shouldBeginSync), object: nil, queue: nil) { notification in
//            self.shouldBeginSync()
//        }
//    }
//    
//    fileprivate func shouldBeginSync() {
//        sync(notify)
//    }
//    
//    fileprivate func notify(success: Bool, sendError: Bool?, recieveError: Bool?, didSendData: Bool?, didRecieveData: Bool?) {
//        guard !(sendError ?? false) && !(recieveError ?? false) && success else {
//            if sendError ?? false, let notificationName = Notifications.self.sendError {
//                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
//            }
//            if recieveError ?? false, let notificationName = Notifications.self.recieveError {
//                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
//            }
//            if let notificationName = Notifications.self.syncError {
//                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
//            }
//            return
//        }
//        
//        if didSendData ?? false, let notificationName = Notifications.self.didSendData {
//            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
//        }
//        
//        if didRecieveData ?? false, let notificationName = Notifications.self.didRecieveData {
//            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
//        }
//        
//        if let notificationName = Notifications.self.didFinishSync {
//            let notifications = NotificationCenter.default
//            notifications.post(name: Notification.Name(rawValue: notificationName), object: self)
//        }
//    }
//}
