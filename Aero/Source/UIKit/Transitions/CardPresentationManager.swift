//
//  CardPresentationManager.swift
//
//  Created by Brian Schrader on 3/7/17.
//

import Foundation
import UIKit


public class CardPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    
    var transitionControllerType: UIPresentationController.Type = CardTransitionController.self
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return transitionControllerType.init(presentedViewController: presented, presenting: presenting)
    }
}
