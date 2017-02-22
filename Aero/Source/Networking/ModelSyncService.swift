// BackgroundModelUpdater
// A convenient protocol that provides an easy,
// thread-safe way of updating models via notifications.
//
// author: Brian Schrader

import Foundation

@objc protocol ModelSyncServiceNotifications {
    static var shouldBeginSync: String { get }
    
    @objc optional static var didFinishSync: String { get }
    
    @objc optional static var didBeginSync: String { get }
    @objc optional static var didRecieveData: String { get }
    @objc optional static var didSendData: String { get }
    
    @objc optional static var syncError: String { get }
    @objc optional static var sendError: String { get }
    @objc optional static var recieveError: String { get }
}

/**
 * A protocol that handles listening to notifications and updating model data asycronously.
 *
 * To use: create a class that fulfills the protocol and fill in the updateData method.
 */
protocol ModelSyncService {
    
    associatedtype Notifications: ModelSyncServiceNotifications
    
    /**
     * This method should perform any updates or networked behavior, then call the callback.
     */
    func sync(_ completionHandler: @escaping (_ success: Bool,
        _ sendError: Bool?, _ recieveError: Bool?,
        _ didSendData: Bool?, _ didRecieveData: Bool?)->())
}

extension ModelSyncService {
    
    func configure() {
        let notifications = NotificationCenter.default
        notifications.addObserver(forName: Notification.Name(rawValue: Notifications.shouldBeginSync), object: nil, queue: nil) { notification in
            self.shouldBeginSync()
        }
    }
    
    fileprivate func shouldBeginSync() {
        sync(notify)
    }
    
    fileprivate func notify(success: Bool, sendError: Bool?, recieveError: Bool?, didSendData: Bool?, didRecieveData: Bool?) {
        guard !(sendError ?? false) && !(recieveError ?? false) && success else {
            if sendError ?? false, let notificationName = Notifications.self.sendError {
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
            }
            if recieveError ?? false, let notificationName = Notifications.self.recieveError {
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
            }
            if let notificationName = Notifications.self.syncError {
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
            }
            return
        }
        
        if didSendData ?? false, let notificationName = Notifications.self.didSendData {
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
        }
        
        if didRecieveData ?? false, let notificationName = Notifications.self.didRecieveData {
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self)
        }
        
        if let notificationName = Notifications.self.didFinishSync {
            let notifications = NotificationCenter.default
            notifications.post(name: Notification.Name(rawValue: notificationName), object: self)
        }
    }
}
