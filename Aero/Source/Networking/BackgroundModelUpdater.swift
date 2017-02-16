// BackgroundModelUpdater
// A convenient protocol that provides an easy,
// thread-safe way of updating models via notifications.
//
// author: Brian Schrader

import Foundation

/**
 * A protocol that handles listening to notifications and updating model data asycronously.
 *
 * To use: create a class that fulfills the protocol and fill in the updateData method.
 */
@objc protocol BackgroundModelUpdater {
    /**
     * A notification identifier to be used to tell the updater to begin processing updates.
     */
    var updateNotification: String { get set }
    /**
     * A notification identifier to be used to tell other instances that the models have been processed.
     */
    @objc optional var updateCompleteNotification: String { get set }
    
    /**
     * This method should perform any updates or networked behavior, then call the callback.
     */
    func updateData(_ completionHandler: @escaping ()->())
}

extension BackgroundModelUpdater {
    
    func configure() {
        let notifications = NotificationCenter.default
        notifications.addObserver(forName: NSNotification.Name(rawValue: updateNotification), object: nil, queue: nil) { notification in
            self.shouldUpdateData()
        }
    }
    
    fileprivate func shouldUpdateData() {
        updateData(notify)
    }
    
    fileprivate func notify() {
        if let completionNotificationName = updateCompleteNotification {
            let notifications = NotificationCenter.default
            notifications.post(name: Notification.Name(rawValue: completionNotificationName), object: nil)
        }
    }
}
