//
//  DrawerController.swift
//  DrawerController
//
//  Created by Andrew James Whitcomb on 5/8/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit

class DrawerController: UIPresentationController {

    weak var drawerControllerDelegate: DrawerControllerDelegate?
    
    var allowsInteractiveOpening: Bool {
        get {
            return drawerControllerDelegate?.drawerControllerShouldAllowInteractivePresenting(self) ?? true
        }
    }
    var interactiveOpening = false
    private weak var drawerPresentationGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    weak var interactivePresenter: DrawerPresentationInteractiveTransition?
    
    var allowsInteractiveClosing: Bool {
        get {
            return drawerControllerDelegate?.drawerControllerShouldAllowInteractiveDismission(self) ?? true
        }
    }
    var interactiveClosing = false
    private lazy var drawerDismissionGestureRecognizer: UIPanGestureRecognizer = {
        let drawerDismissionGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawerController.handleDismissionGesture(_:)))
        drawerDismissionGestureRecognizer.maximumNumberOfTouches = 1
        drawerDismissionGestureRecognizer.delegate = self
        drawerDismissionGestureRecognizer.isEnabled = false
        return drawerDismissionGestureRecognizer
    }()
    private lazy var dimmingViewDimissionGestureRecognizer: UIPanGestureRecognizer = {
        let dimmingViewDimissionGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawerController.handleDismissionGesture(_:)))
        dimmingViewDimissionGestureRecognizer.maximumNumberOfTouches = 1
        dimmingViewDimissionGestureRecognizer.delegate = self
        dimmingViewDimissionGestureRecognizer.isEnabled = false
        return dimmingViewDimissionGestureRecognizer
    }()
    weak var interactiveDismisser: DrawerDismissionInteractiveTransition?
    
    weak var dimmingView: UIView?
    
    func setupDimmingView() {
        let dimmingView = UIView(frame: self.containerView?.bounds ?? CGRect.zero)
        dimmingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        dimmingView.alpha = 0
        dimmingView.addGestureRecognizer(dimmingViewDimissionGestureRecognizer)
        self.containerView?.addSubview(dimmingView)
        self.dimmingView = dimmingView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            let drawerWidth = self.presentedViewController.preferredContentSize.width
            let contentHeight = self.containerView!.bounds.size.height
            return CGRect(x: 0, y: 0, width: drawerWidth, height: contentHeight)
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        var startFrame = frameOfPresentedViewInContainerView
        startFrame.origin.x -= startFrame.width
        if let presentedView = self.presentedView, let containerView = self.containerView {
            presentedView.frame = startFrame
            containerView.addSubview(presentedView)
        }
        
        setupDimmingView()
        
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { [unowned self] (context) in
            self.dimmingView?.alpha = 1
        }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            return
        }
        
        dimmingViewDimissionGestureRecognizer.isEnabled = true
        self.presentedView?.addGestureRecognizer(drawerDismissionGestureRecognizer)
        drawerDismissionGestureRecognizer.isEnabled = true
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { [unowned self] (context) in
            self.dimmingView?.alpha = 0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed {
            return
        }
        
        dimmingViewDimissionGestureRecognizer.isEnabled = false
        drawerDismissionGestureRecognizer.isEnabled = false
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
        switch presentationGesture.state {
        case .began:
            interactiveOpening = true
            self.presentingViewController.present(self.presentedViewController, animated: true, completion: nil)
        case .changed:
            let velocity = presentationGesture.velocity(in: presentationGesture.view)
            guard let interactivePresenter = self.interactivePresenter, velocity.x > velocity.y else {
                return
            }
            
            let locationInView = presentationGesture.location(in: presentationGesture.view)
            interactivePresenter.update(interactionXPosition: locationInView.x)
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

// MARK: Dismissal Gestures/Interactive Closing

extension DrawerController {
    
    @objc func handleDismissionGesture(_ dismissionGesture: UIScreenEdgePanGestureRecognizer) {
        switch dismissionGesture.state {
        case .began:
            if !interactiveClosing {
                interactiveClosing = true
                self.presentingViewController.dismiss(animated: true, completion: nil)
            } else if dismissionGesture == drawerDismissionGestureRecognizer {
                let interactiveXTranslation = interactiveDismisser?.currentInteractionXTranslation ?? 0
                drawerDismissionGestureRecognizer.setTranslation(CGPoint(x: interactiveXTranslation, y: 0), in: drawerDismissionGestureRecognizer.view)
            }
        case .changed:
            let velocity = dismissionGesture.velocity(in: dismissionGesture.view)
            guard let interactiveDismisser = self.interactiveDismisser, velocity.x > velocity.y else {
                return
            }
            
            
            switch dismissionGesture {
            case drawerDismissionGestureRecognizer:
                let interactionXTranslation = dismissionGesture.translation(in: dismissionGesture.view).x
                interactiveDismisser.update(interactionXTranslation: interactionXTranslation)
            case dimmingViewDimissionGestureRecognizer:
                let interactionXPosition = dismissionGesture.location(in: dismissionGesture.view).x
                interactiveDismisser.update(interactionXPosition: interactionXPosition)
            default:
                break
            }
        case .ended:
            guard let interactiveDismisser = self.interactiveDismisser else {
                return
            }
            
            if interactiveDismisser.percentComplete > 0.5 {
                interactiveDismisser.finish()
            } else {
                interactiveDismisser.cancel()
            }
            interactiveOpening = false
        case .cancelled:
            interactiveDismisser?.cancel()
            interactiveClosing = false
        default:
            break
        }
    }
    
}

// MARK: UIGestureRecognizerDelegate

extension DrawerController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case drawerPresentationGestureRecognizer:
            return allowsInteractiveOpening
        case drawerDismissionGestureRecognizer:
            return allowsInteractiveClosing
        case dimmingViewDimissionGestureRecognizer:
            return allowsInteractiveClosing
        default:
            return false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(gestureRecognizer == drawerDismissionGestureRecognizer && otherGestureRecognizer == dimmingViewDimissionGestureRecognizer)
    }
    
}

// MARK: UIViewControllerTransitioningDelegate

extension DrawerController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self
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
            let interactiveDismission = DrawerDismissionInteractiveTransition()
            self.interactiveDismisser = interactiveDismission
            return interactiveDismission
        }
        return nil
    }
    
}
