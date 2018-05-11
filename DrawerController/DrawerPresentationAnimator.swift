//
//  DrawerPresentationAnimator.swift
//  DrawerController
//
//  Created by Andrew James Whitcomb on 5/9/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit

class DrawerPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animator(_ transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let toView = toViewController.view!
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let animationDuration = transitionDuration(using: transitionContext)
        
        let animator = UIViewPropertyAnimator(duration: animationDuration, curve: .linear) {
            toView.frame = finalFrame
        }
        animator.addCompletion { (finalPosition) in
            let complete = finalPosition == .end
            transitionContext.completeTransition(complete)
        }
        return animator
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        animator(transitionContext).startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return animator(transitionContext)
    }
    
}
