// DispatchGroupResultsStore
//
// author: Brian Schrader

import Foundation


class DispatchGroupResultsStore<T> {
    
    var groupHash: Int!
    var results: [T] = []
    var maxTasks = 0
    var tasks = 0
    
    var completionHandler: ((_ results: [T])->())? = nil
    
    init(group: DispatchGroup) {
        groupHash = group.hashValue
    }
    
    public func append(contentsOf taskResults: [T]?, group: DispatchGroup) {
        guard group.hashValue == groupHash else { return }
        if let taskResults = taskResults {
            results.append(contentsOf: taskResults)
        }
        tasks += 1
        
        if tasks == maxTasks {
            handleAllComplete(completionHandler: completionHandler)
        }
    }
    
    private func handleAllComplete(completionHandler: ((_ results: [T])->())?) {
        guard let completionHandler = completionHandler else { return }
        completionHandler(results)
    }
}
