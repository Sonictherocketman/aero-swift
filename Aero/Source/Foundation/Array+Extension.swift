// Array+Functional+Extension.swift
// A set of functional methods for arrays.
//
// author: Brian Schrader
// since: 2/6/17.

import Foundation

extension Array {
    
    /**
     * Determine if all elements in the array are true.
     */
    func all() -> Bool {
        return all { $0 as? Bool == true }
    }
    
    
    /**
     * Determine if all elements in the array meet some criteria.
     */
    func all(_ criteria: (_ element: Element)->(Bool)) -> Bool {
        for element in self {
            if !criteria(element) {
                return false
            }
        }
        return true
    }
    
    /**
     * Determine if any element in the array is true.
     */
    func any() -> Bool {
        return any { $0 as? Bool == true }
    }
    
    /**
     * Determine if any element in the array meets some criteria.
     */
    func any(_ criteria: (_ element: Element)->(Bool)) -> Bool {
        for element in self {
            if criteria(element) {
                return true
            }
        }
        return false
    }
}
