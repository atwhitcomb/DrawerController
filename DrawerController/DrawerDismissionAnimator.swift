//
//  DrawerDismissionAnimator.swift
//  DrawerController
//
//  Created by Andrew James Whitcomb on 5/10/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit

public class DrawerDismissionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func animator(_ transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        let fromView = transitionContext.view(forKey: .from)!
        var finalFrame = fromView.frame
        finalFrame.origin.x -= finalFrame.width
        let animationDuration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: animationDuration, curve: .linear) {
            fromView.frame = finalFrame
        }
        animator.addCompletion { (finalPosition) in
            let complete = finalPosition == .end
            transitionContext.completeTransition(complete)
        }
        return animator
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        animator(transitionContext).startAnimation()
    }
    
    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return animator(transitionContext)
    }
    
}
