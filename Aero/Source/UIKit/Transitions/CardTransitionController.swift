//
//  CardTransitionController.swift
//
//  Created by Brian Schrader on 3/7/17.
//

import Foundation
import UIKit


public class CardTransitionController: UIPresentationController {
    
    var VIEW_CONTROLLER_PERCENT_HEIGHT: CGFloat = 0.90
    var VIEW_CONTROLLER_PERCENT_WIDTH: CGFloat = 0.94
    
    private var dimmedView: UIView!
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmedView()
    }
    
    override public func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmedView, at: 0)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmedView]|",
                                           options: [], metrics: nil, views: ["dimmedView": dimmedView]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmedView]|",
                                           options: [], metrics: nil, views: ["dimmedView": dimmedView]))
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmedView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmedView.alpha = 1.0
        })
        
        //        coordinator.animate(alongsideTransition: { _ in
        //            self.presentingViewController.view.frame = self.frameOfPresentingView
        //            self.presentingViewController.view.layer.cornerRadius = 30
        //        })
    }
    
    override public func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmedView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmedView.alpha = 0.0
        })
        
        coordinator.animate(alongsideTransition: { _ in
            self.presentingViewController.view.frame = self.containerView!.frame
        })
    }
    
    override public func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        frame.origin.y = containerView!.frame.height * (1.0 - VIEW_CONTROLLER_PERCENT_HEIGHT)
        return frame
    }
    
    var frameOfPresentingView: CGRect {
        var frame: CGRect = .zero
        frame.size = CGSize(width: containerView!.frame.width * VIEW_CONTROLLER_PERCENT_WIDTH, height: containerView!.frame.height - 20)
        // % from the top and centered in the bottom.
        frame.origin.y = 20
        frame.origin.x = containerView!.frame.width * (1.0 - VIEW_CONTROLLER_PERCENT_WIDTH) / 2
        return frame
    }
    
    override public func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height * VIEW_CONTROLLER_PERCENT_HEIGHT)
    }
    
    // MARK: Gesture Recognizers
    
    dynamic func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
    // MARK: Private Methods
    
    private func setupDimmedView() {
        dimmedView = UIView()
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        dimmedView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmedView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        dimmedView.addGestureRecognizer(recognizer)
    }
}


public class ShortCardTransitionController: CardTransitionController {
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        VIEW_CONTROLLER_PERCENT_HEIGHT = 0.33
    }
    
}


public class MediumCardTransitionController: CardTransitionController {
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        VIEW_CONTROLLER_PERCENT_HEIGHT = 0.66
    }
    
}
