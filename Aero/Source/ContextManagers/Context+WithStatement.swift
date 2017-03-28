// With Statements and a Context Protocol
// An implementation of Python's `with` statement in swift. 
//
// author: Brian Schrader

import Foundation
import CoreData

public protocol Context {
    func enter()
    func exit(_ error: Error?)
}

public func with<C: Context>(_ context: C?, block:(_ context: C) throws -> () ) {
    guard let context = context else { return }
    
    context.enter()
    
    do {
        try block(context)
        context.exit(nil)
    } catch {
        context.exit(error)
    }
}
