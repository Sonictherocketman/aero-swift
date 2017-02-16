// Int+Extension.swift
//
// author: Brian Schrader

import Foundation


extension Int {
    
    var rank: String {
        get {
            guard ![11, 12, 13].contains(self) else {
                return "\(self)th"
            }
            switch (self % 10) {
            case 1:
                return "\(self)st"
            case 2:
                return "\(self)nd"
            case 3:
                return "\(self)rd"
            default:
                return "\(self)th"
            }
        }
    }
    
}
