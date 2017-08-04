// Model Sync Service Delegate
// Handles events sent from a given model sync service.
//
// author: Brian Schrader

import Foundation

/**
 * Model Sync Service Delegates respond to events from a given model sync service
 * and can react to provide useful feedback during processing.
 *
 * All methods are optional.
 */
public protocol ModelSyncServiceDelegate {
    // MARK: Sync Event Responder Methods
    
    /**
     * Allows the delegate to respond and prepare for a given sync service to begin
     * syncing it's data.
     */
    func modelSyncServiceWillBeginSync(_ modelSyncService: ModelSyncService)
    
    /**
     * Allows the delegate to respond and prepare for a given sync service once it's
     * begun syncing it's data.
     */
    func modelSyncServiceDidBeginSync(_ modelSyncService: ModelSyncService)
    
    /**
     * The delegate has finished it's syncing operations. This is the final update handed to the
     * delegate during syncing. If an error was encountered, then it will be passed to this method.
     */
    func modelSyncServiceDidFinishSync(_ modelSyncService: ModelSyncService, error: Error?)
    
    // MARK: Data Handling Methods
    
    /**
     * The given sync service has successfully received data from the remote store.
     */
    func modelSyncService(_ modelSyncService: ModelSyncService, didRecieveData: Any?)
    
    /**
     * The given sync service will sent data to the remote store.
     */
    func modelSyncService(_ modelSyncService: ModelSyncService, willSendData: Any?)
    
    /**
     * The given sync service has successfully sent data to the remote store.
     */
    func modelSyncService(_ modelSyncService: ModelSyncService, didSendData: Any?)
    
    // MARK: Error Handling Methods
    
    /**
     * The given sync service has encountered an error while attempting to send or receive
     * data from or to the remote store.
     *
     * For more detailed handling of sync errors, implement `didEncounterErrorSendingData` or
     * `didEncounterErrorReceivingData`.
     */
    func modelSyncService(_ modelSyncService: ModelSyncService, didEncounterSyncError: Error)
    
    
    /**
     * The given sync service has encountered an error while attempting to send data to the remote store.
     *
     * Returning true will cause the sync service to attempt a rety of the send.
     */
    @discardableResult func modelSyncService(_ modelSyncService: ModelSyncService, didEncounterError: Error, sendingData: Any?) -> Bool
    
    /**
     * The given sync service has encountered an error while attempting to receive data to the remote store.
     *
     * Depending on the cause of the issue, returning true will cause the sync service to attempt a rety of the receive.
     * In some cases the error was due to networking issues that can cause the error to be unrecoverable.
     */
    @discardableResult func modelSyncService(_ modelSyncService: ModelSyncService, didEncounterError: Error, receivingData: Any?) -> Bool
}

extension ModelSyncServiceDelegate {
    
    // MARK: Sync Event Responder Methods
    
    public func modelSyncServiceWillBeginSync(_ modelSyncService: ModelSyncService) {}
    
    public func modelSyncServiceDidBeginSync(_ modelSyncService: ModelSyncService) {}
    
    public func modelSyncServiceDidFinishSync(_ modelSyncService: ModelSyncService, error: Error?) {}
    
    // MARK: Data Handling Methods
    
    public func modelSyncService(_ modelSyncService: ModelSyncService, didRecieveData: Any?) {}
    
    public func modelSyncService(_ modelSyncService: ModelSyncService, willSendData: Any?) {}
    
    public func modelSyncService(_ modelSyncService: ModelSyncService, didSendData: Any?) {}
    
    // MARK: Error Handling Methods
    
    public func modelSyncService(_ modelSyncService: ModelSyncService, didEncounterSyncError: Error) {}
    
    
    @discardableResult public func modelSyncService(_ modelSyncService: ModelSyncService, didEncounterError: Error, sendingData: Any?) -> Bool {
        return false
    }
    
    @discardableResult public func modelSyncService(_ modelSyncService: ModelSyncService, didEncounterError: Error, receivingData: Any?) -> Bool {
        return false
    }
}


public class DataTransferError: Error {
    
    var description: String?
    
    init(_ description: String?) {
        self.description = description
    }
}


public class NetworkNotReadyError: Error {}


/**
 * An implementation of the `ModelSyncServiceDelegate` protocol that sends NSNotifications
 * whenever an event is detected.
 *
 * Any number of listners can be notified this way via these notifications.
 * For more information on what notifications are expected, see each event method's documentation,
 * but the general format is as follows:
 * `notification name = modelSyncService class name + event identifier`
 */
public class NotificationBackedModelSyncServiceDelegate: ModelSyncServiceDelegate {
    
    public func modelSyncServiceWillBeginSync(_ modelSyncService: ModelSyncService) {
        let identifier = "\(String(describing: type(of: modelSyncService))).willBeginSync"
        send(identifier)
    }
    
    public func modelSyncServiceDidBeginSync(_ modelSyncService: ModelSyncService) {
        let identifier = "\(String(describing: type(of: modelSyncService))).didBeginSync"
        send(identifier)
    }
    
    public func modelSyncServiceDidFinishSync(_ modelSyncService: ModelSyncService, error: Error?) {
        let identifier = "\(String(describing: type(of: modelSyncService))).didFinishSync"
        send(identifier)
    }
    
    public func modelSyncService(_ modelSyncService: ModelSyncService, didRecieveData: Any?) {
        let identifier = "\(String(describing: type(of: modelSyncService))).didRecieveData"
        send(identifier)
    }
    
    public func modelSyncService(_ modelSyncService: ModelSyncService, didSendData: Any?) {
        let identifier = "\(String(describing: type(of: modelSyncService))).didSendData"
        send(identifier)
    }
    
    public func modelSyncService(_ modelSyncService: ModelSyncService, didEncounterSyncError: Error?) {
        let identifier = "\(String(describing: type(of: modelSyncService))).didEncounterSyncError"
        send(identifier)
    }
    
    @discardableResult public func modelSyncService(_ modelSyncService: ModelSyncService, didEncounterError: Error?, sendingData: Any?) -> Bool {
        let identifier = "\(String(describing: type(of: modelSyncService))).didEncounterErrorSendingData"
        send(identifier)
        return false
    }
    
    @discardableResult public func modelSyncService(_ modelSyncService: ModelSyncService, didEncounterError: Error?, receivingData: Any?) -> Bool {
        let identifier = "\(String(describing: type(of: modelSyncService))).didEncounterErrorReceivingData"
        send(identifier)
        return false
    }
    
    // MARK: Private Methods
    
    func send(_ notificationName: String) {
        let notification = Notification.Name(rawValue: notificationName)
        NotificationCenter.default.post(name: notification, object: nil)
    }
}
