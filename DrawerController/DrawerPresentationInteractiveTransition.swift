//
//  DrawerPresentationInteractiveTransition.swift
//  DrawerController
//
//  Created by Andrew James Whitcomb on 5/10/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit

class DrawerPresentationInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    var presentedViewWidth: CGFloat!
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)!
        presentedViewWidth = transitionContext.finalFrame(for: toViewController).width
        super.startInteractiveTransition(transitionContext)
    }
    
    func update(interactionXPosition: CGFloat) {
        update(min(interactionXPosition / presentedViewWidth, 1))
        
    }

}
