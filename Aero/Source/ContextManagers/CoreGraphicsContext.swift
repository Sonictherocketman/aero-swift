//
//  CoreGraphicsContexts.swift
//  MyGeneRank
//
//  Created by Brian Schrader on 9/1/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

/*!
 * Runs a block of draw code in a safe, new context.
 */
class SafeCGContext: Context {
    
    var cgContext: CGContext?
    
    func enter() {
        cgContext = UIGraphicsGetCurrentContext()
        cgContext?.saveGState()
    }
    
    func exit(_ error: Error?) {
        cgContext?.restoreGState()
    }
}


class TransparentCGContext: SafeCGContext {
    
    override func enter() {
        super.enter()
        cgContext?.beginTransparencyLayer(auxiliaryInfo: nil)
    }
    
    override func exit(_ error: Error?) {
        super.exit(error)
        cgContext?.endTransparencyLayer()
    }
}
