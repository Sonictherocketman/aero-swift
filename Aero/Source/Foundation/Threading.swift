//
//  MainThreadContext.swift
//  MyGeneRank
//
//  Created by Brian Schrader on 3/8/17.
//  Copyright © 2017 Apple, Inc. All rights reserved.
//

import Foundation


public func ensureMainThread(completionHandler: @escaping ()->()) {
    if !Thread.isMainThread {
        DispatchQueue.main.sync {
            completionHandler()
        }
    } else {
        completionHandler()
    }
}
