//
//  DrawerDismissionInteractiveTransition.swift
//  DrawerController
//
//  Created by Andrew James Whitcomb on 5/13/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit

public class DrawerDismissionInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    private(set) var presentedViewWidth: CGFloat?
    var currentInteractionXTranslation: CGFloat {
        get {
            return -1 * percentComplete * (presentedViewWidth ?? 0)
        }
    }
    
    override public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        presentedViewWidth = transitionContext.finalFrame(for: fromViewController).width
        super.startInteractiveTransition(transitionContext)
    }
    
    func update(interactionXPosition: CGFloat) {
        guard let presentedViewWidth = self.presentedViewWidth else {
            return
        }
        
        let interactionXTranslation = min(interactionXPosition - presentedViewWidth, 0)
        self.update(interactionXTranslation: interactionXTranslation)
    }
    
    func update(interactionXTranslation: CGFloat) {
        guard let presentedViewWidth = self.presentedViewWidth else {
            return
        }
        
        var percentComplete = -1 * interactionXTranslation / presentedViewWidth
        percentComplete = min(percentComplete, 1)
        percentComplete = max(percentComplete, 0)
        update(percentComplete)
    }

}
