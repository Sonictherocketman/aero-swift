// Int+Extension.swift
//
// author: Brian Schrader

import Foundation


extension Int {
    
    var rank: String {
        get {
            switch (self % 10) {
            case 1:
                return "\(self)st"
            case 2:
                return "\(self)nd"
            case 3:
                return "\(self)rd"
            case 11, 12, 13:
                return "\(self)th"
            default:
                return "\(self)th"
            }
        }
    }
    
}
