//
//  DrawerController.swift
//  DrawerController
//
//  Created by Andrew James Whitcomb on 5/8/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit

class DrawerController: NSObject {

    weak var delegate: DrawerControllerDelegate?
    
    weak var presentationController: DrawerPresentationController!
    
    var allowsInteractiveOpening: Bool {
        get {
            return delegate?.drawerControllerShouldAllowInteractivePresenting(self) ?? false
        }
    }
    var interactiveOpening = false
    private weak var drawerPresentationGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    weak var interactivePresenter: DrawerPresentationInteractiveTransition?
    
    var allowsInteractiveClosing: Bool {
        get {
            return delegate?.drawerControllerShouldAllowInteractiveDismission(self) ?? false
        }
    }
    var interactiveClosing = false
    private weak var drawerDismissionGestureRecognizer: UIPanGestureRecognizer?
    weak var interactiveDismisser: AnyObject?
    
    convenience init(delegate: DrawerControllerDelegate?) {
        self.init()
        self.delegate = delegate
    }
    
}

// MARK: Presentation Gesture/Interactive Opening

extension DrawerController {
 
    func attachPresentationGesture(_ view: UIView) {
        let drawerPresentationGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(DrawerController.handlePresentationGesture))
        drawerPresentationGestureRecognizer.edges = .left
        
        self.drawerPresentationGestureRecognizer = drawerPresentationGestureRecognizer
        view.addGestureRecognizer(drawerPresentationGestureRecognizer)
    }
    
    @objc func handlePresentationGesture(_ presentationGesture: UIScreenEdgePanGestureRecognizer) {
        guard let delegate = self.delegate else {
            return
        }
        
        switch presentationGesture.state {
        case .began:
            interactiveOpening = true
            delegate.drawerControllerPresentationGestureBegan(self)
        case .changed:
            guard let interactivePresenter = self.interactivePresenter else {
                return
            }
        // TODO:
        case .ended:
            guard let interactivePresenter = self.interactivePresenter else {
                return
            }
            
            if interactivePresenter.percentComplete > 0.5 {
                interactivePresenter.finish()
            } else {
                interactivePresenter.cancel()
            }
            interactiveOpening = false
        case .cancelled:
            interactivePresenter?.cancel()
            interactiveOpening = false
        default:
            break
        }
    }
    
}

// MARK: UIGestureRecognizerDelegate

extension DrawerController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == drawerPresentationGestureRecognizer {
            return allowsInteractiveOpening
        } else if gestureRecognizer == drawerDismissionGestureRecognizer {
            return allowsInteractiveClosing
        }
        
        return false
    }
    
}

// MARK: UIViewControllerTransitioningDelegate

extension DrawerController: UIViewControllerTransitioningDelegate {
    
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
        if interactiveOpening {
            let interactivePresenter = DrawerPresentationInteractiveTransition()
            self.interactivePresenter = interactivePresenter
            return interactivePresenter
        }
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveClosing {
            // TODO:
        }
        return nil
    }
    
}
