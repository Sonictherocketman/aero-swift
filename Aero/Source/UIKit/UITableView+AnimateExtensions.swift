//
//  UITableView+AnimationExtention.swift
//
//  Created by Brian Schrader on 6/6/17.
//

import Foundation
import UIKit


public extension UITableView {
    
    /**
     Set the edge insets to zero and animate the transition.
     */
    public func animateEdgeInsetsToZero(_ duration: Double = 0.3) {
        UIView.animate(withDuration: duration) {
            self.zeroEdgeInsets()
        }
    }
    
    /**
     Set the edge insets to zero.
     */
    public func zeroEdgeInsets() {
        contentInset = UIEdgeInsets.zero
        scrollIndicatorInsets = UIEdgeInsets.zero
    }
}
