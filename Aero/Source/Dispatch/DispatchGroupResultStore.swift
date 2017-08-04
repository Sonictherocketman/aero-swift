// DispatchGroupResultsStore
//
// author: Brian Schrader

import Foundation


public protocol ResultMapDispatchGroupDelegate {
    // Progress Handlers
    func taskDidComplete(_ resultMapDispatchGroup: ResultMapDispatchGroup, with results: [Any]?)
    func didFinish(_ resultMapDispatchGroup: ResultMapDispatchGroup, results: [Any]?)
}

extension ResultMapDispatchGroupDelegate {
    // Error Handlers
    func didFailToAppendResult(_ resultMapDispatchGroup: ResultMapDispatchGroup, failedResult: [Any]?) {}
}


public class ResultMapDispatchGroup {
    
    var tasks = 0

    public var results: [Any] = []
    public var maxTasks = 0
    public var delegate: ResultMapDispatchGroupDelegate?
    public var identifier: String

    public init(identifier: String) {
        self.identifier = identifier
    }
    
    public func append(contentsOf taskResults: [Any]?) {
        self.delegate?.taskDidComplete(self, with: taskResults)
        if let taskResults = taskResults {
            results.append(contentsOf: taskResults)
        }
        tasks += 1
        
        if tasks == maxTasks {
            self.delegate?.didFinish(self, results: results)
        }
    }
}
