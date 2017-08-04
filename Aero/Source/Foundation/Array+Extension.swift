import Foundation

//  Array+Functional+Extension.swift
//  A set of functional methods for arrays.
//  Created by Brian Schrader on 2/6/17.
public extension Array {
    
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


public extension Array {
    func splitBy(subSize: Int) -> [[Element]] {
        return stride(from: 0, to: underestimatedCount, by: subSize).map { startIndex in
            let endIndex = startIndex + subSize <= underestimatedCount ? startIndex + subSize : underestimatedCount
            return Array(self[startIndex ..< endIndex])
        }
    }
}
