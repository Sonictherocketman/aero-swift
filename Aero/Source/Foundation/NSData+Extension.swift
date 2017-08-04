// Data+Extension
//
// author: Brian Schrader

import Foundation

// From: http://stackoverflow.com/questions/26501276/converting-hex-string-to-nsdata-in-swift#26502285

public extension Data {
    
    /// Create hexadecimal string representation of `Data` object.
    ///
    /// - returns: `String` representation of this `Data` object.
    
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
}
