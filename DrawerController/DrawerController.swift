//
//  DrawerController.swift
//  DrawerController
//
//  Created by Andrew James Whitcomb on 5/8/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit

class DrawerController: NSObject, UIViewControllerTransitioningDelegate {
    
    var interactionAllowed: Bool = true
    
    weak var drawerPresentationGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    weak var presentationController: DrawerPresentationController!
    weak var interactivePresenter: DrawerPresentationInteractiveTransition!
    weak var interactiveDismisser: AnyObject!
    
    deinit {
    
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        //We have to
        let presentationController = DrawerPresentationController(presentedViewController: presented, presenting: presenting)
        self.presentationController = presentationController
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerPresentationAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerDismissionAnimator()
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactionAllowed {
            let interactivePresenter = DrawerPresentationInteractiveTransition()
            self.interactivePresenter = interactivePresenter
            return interactivePresenter
        }
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
}
