//
//  CoreDataWithContextManager.swift
//  MyGeneRank
//
//  Created by Brian Schrader on 7/1/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import Foundation
import CoreData

protocol Context {
    func enter()
    func exit(_ error: Error?)
}

func with<C: Context>(_ context: C?, block:(_ context: C) throws -> () ) {
    guard let context = context else { return }
    
    context.enter()
    
    do {
        try block(context)
        context.exit(nil)
    } catch {
        context.exit(error)
    }
}
