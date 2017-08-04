// Core Graphics Contexts
//
// author: Brian Schrader

import Foundation
import UIKit
import CoreGraphics

/*!
 * Runs a block of draw code in a safe, new context.
 */
public class SafeCGContext: Context {
    
    public var cgContext: CGContext?
    
    public func enter() {
        cgContext = UIGraphicsGetCurrentContext()
        cgContext?.saveGState()
    }
    
    public func exit(_ error: Error?) {
        cgContext?.restoreGState()
    }
}


public class TransparentCGContext: SafeCGContext {
    
    override public func enter() {
        super.enter()
        cgContext?.beginTransparencyLayer(auxiliaryInfo: nil)
    }
    
    override public func exit(_ error: Error?) {
        super.exit(error)
        cgContext?.endTransparencyLayer()
    }
}
