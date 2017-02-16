// Core Graphics Contexts
//
// author: Brian Schrader

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
