//
//  DrawerDismissionInteractiveTransition.swift
//  DrawerController
//
//  Created by Andrew James Whitcomb on 5/13/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit

class DrawerDismissionInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    private var presentedViewWidth: CGFloat!
    private(set) var currentInteractionXTranslation: CGFloat = 0
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        presentedViewWidth = transitionContext.finalFrame(for: fromViewController).width
        super.startInteractiveTransition(transitionContext)
    }
    
    func update(interactionXPosition: CGFloat) {
        let interactionXTranslation = max(presentedViewWidth - presentedViewWidth, 0)
        self.update(interactionXTranslation: interactionXTranslation)
    }
    
    func update(interactionXTranslation: CGFloat) {
        currentInteractionXTranslation = interactionXTranslation
        var percentComplete = (presentedViewWidth + interactionXTranslation) / presentedViewWidth
        percentComplete = min(percentComplete, 1)
        percentComplete = max(percentComplete, 0)
        update(percentComplete)
    }

}
