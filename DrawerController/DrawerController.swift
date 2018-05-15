//
//  DrawerController.swift
//  DrawerController
//
//  Created by Andrew James Whitcomb on 5/8/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit

public class DrawerController: UIPresentationController {

    public weak var drawerControllerDelegate: DrawerControllerDelegate?
    
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
        let drawerDismissionGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawerController.handlePanDismissionGesture(_:)))
        drawerDismissionGestureRecognizer.maximumNumberOfTouches = 1
        drawerDismissionGestureRecognizer.delegate = self
        drawerDismissionGestureRecognizer.isEnabled = false
        return drawerDismissionGestureRecognizer
    }()
    private lazy var dimmingViewDismissionPanGestureRecognizer: UIPanGestureRecognizer = {
        let dimmingViewDismissionPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawerController.handlePanDismissionGesture(_:)))
        dimmingViewDismissionPanGestureRecognizer.maximumNumberOfTouches = 1
        dimmingViewDismissionPanGestureRecognizer.delegate = self
        dimmingViewDismissionPanGestureRecognizer.isEnabled = false
        return dimmingViewDismissionPanGestureRecognizer
    }()
    private lazy var dimmingViewDismissionTapGestureRecognizer: UITapGestureRecognizer = {
        let dimmingViewDismissionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawerController.handleTapDismissionGesture(_:)))
        dimmingViewDismissionTapGestureRecognizer.delegate = self
        dimmingViewDismissionTapGestureRecognizer.isEnabled = false
        return dimmingViewDismissionTapGestureRecognizer
    }()
    private var currentDismissionGestureRecognizer: UIGestureRecognizer?
    weak var interactiveDismisser: DrawerDismissionInteractiveTransition?
    
    public weak var dimmingView: UIView?
    
    required public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.transitioningDelegate = self
        presentedViewController.modalPresentationStyle = .custom
        attachPresentationGesture(presentingViewController.view)
    }
    
    func setupDimmingView() {
        let dimmingView = UIView(frame: self.containerView?.bounds ?? CGRect.zero)
        dimmingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        dimmingView.alpha = 0
        self.containerView?.insertSubview(dimmingView, at: 0)
        self.dimmingView = dimmingView
    }
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        get {
            let drawerWidth = self.presentedViewController.preferredContentSize.width
            let contentHeight = self.containerView!.bounds.size.height
            return CGRect(x: 0, y: 0, width: drawerWidth, height: contentHeight)
        }
    }
    
    override public func containerViewWillLayoutSubviews() {
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override public func presentationTransitionWillBegin() {
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
    
    override public func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            return
        }
        
        dimmingView?.addGestureRecognizer(dimmingViewDismissionPanGestureRecognizer)
        dimmingViewDismissionPanGestureRecognizer.isEnabled = true
        
        dimmingView?.addGestureRecognizer(dimmingViewDismissionTapGestureRecognizer)
        dimmingViewDismissionTapGestureRecognizer.isEnabled = true
        
        presentedView?.addGestureRecognizer(drawerDismissionGestureRecognizer)
        drawerDismissionGestureRecognizer.isEnabled = true
    }
    
    override public func dismissalTransitionWillBegin() {
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { [unowned self] (context) in
            self.dimmingView?.alpha = 0
            }, completion: nil)
    }
    
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed {
            return
        }
        
        dimmingView?.removeGestureRecognizer(dimmingViewDismissionPanGestureRecognizer)
        dimmingViewDismissionPanGestureRecognizer.isEnabled = false
        
        dimmingView?.addGestureRecognizer(dimmingViewDismissionTapGestureRecognizer)
        dimmingViewDismissionTapGestureRecognizer.isEnabled = false
        
        presentedView?.removeGestureRecognizer(drawerDismissionGestureRecognizer)
        drawerDismissionGestureRecognizer.isEnabled = false
    }

}

// MARK: Presentation Gesture/Interactive Opening

extension DrawerController {
 
    public func attachPresentationGesture(_ view: UIView) {
        let drawerPresentationGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(DrawerController.handlePresentationGesture))
        drawerPresentationGestureRecognizer.edges = .left
        
        self.drawerPresentationGestureRecognizer = drawerPresentationGestureRecognizer
        view.addGestureRecognizer(drawerPresentationGestureRecognizer)
    }
    
    @objc func handlePresentationGesture(_ presentationGesture: UIScreenEdgePanGestureRecognizer) {        
        switch presentationGesture.state {
        case .began:
            interactiveOpening = true
            presentingViewController.present(presentedViewController, animated: true, completion: nil)
        case .changed:
            let velocity = presentationGesture.velocity(in: presentationGesture.view)
            guard let interactivePresenter = self.interactivePresenter, fabs(velocity.x) > fabs(velocity.y) else {
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
    
    @objc func handlePanDismissionGesture(_ dismissionGesture: UIPanGestureRecognizer) {
        switch (dismissionGesture.state, dismissionGesture) {
        case (.began, _):
            interactiveClosing = true
            currentDismissionGestureRecognizer = dismissionGesture
            if let interactiveDismisser = self.interactiveDismisser {
                interactiveDismisser.pause()
                let interactiveXTranslation = interactiveDismisser.currentInteractionXTranslation
                dismissionGesture.setTranslation(CGPoint(x: interactiveXTranslation, y: 0), in: drawerDismissionGestureRecognizer.view)
            } else {
                presentingViewController.dismiss(animated: true, completion: nil)
            }
            
            if dismissionGesture == drawerDismissionGestureRecognizer {
                dimmingViewDismissionPanGestureRecognizer.isEnabled = false
                dimmingViewDismissionPanGestureRecognizer.isEnabled = true
            }
        case (.changed, currentDismissionGestureRecognizer):
            let velocity = dismissionGesture.velocity(in: dismissionGesture.view)
            guard let interactiveDismisser = self.interactiveDismisser, fabs(velocity.x) > fabs(velocity.y) else {
                return
            }
            
            switch dismissionGesture {
            case drawerDismissionGestureRecognizer:
                let interactionXTranslation = dismissionGesture.translation(in: dismissionGesture.view).x
                interactiveDismisser.update(interactionXTranslation: interactionXTranslation)
            case dimmingViewDismissionPanGestureRecognizer:
                let interactionXPosition = dismissionGesture.location(in: dismissionGesture.view).x
                interactiveDismisser.update(interactionXPosition: interactionXPosition)
            default:
                break
            }
        case (.ended, currentDismissionGestureRecognizer):
            guard let interactiveDismisser = self.interactiveDismisser else {
                return
            }
            
            if interactiveDismisser.percentComplete > 0.5 {
                interactiveDismisser.finish()
            } else {
                interactiveDismisser.cancel()
            }
            interactiveClosing = false
        case (.cancelled, currentDismissionGestureRecognizer):
            interactiveDismisser?.cancel()
            interactiveClosing = false
        default:
            break
        }
    }
    
    @objc func handleTapDismissionGesture(_ dismissionGesture: UIPanGestureRecognizer) {
        if dismissionGesture.state == .ended {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
}

// MARK: UIGestureRecognizerDelegate

extension DrawerController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case drawerPresentationGestureRecognizer:
            return allowsInteractiveOpening
        case drawerDismissionGestureRecognizer:
            return allowsInteractiveClosing
        case dimmingViewDismissionPanGestureRecognizer:
            return allowsInteractiveClosing
        case dimmingViewDismissionTapGestureRecognizer:
            return !interactiveClosing
        default:
            return false
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(gestureRecognizer == drawerDismissionGestureRecognizer && otherGestureRecognizer == dimmingViewDismissionPanGestureRecognizer)
    }
    
}

// MARK: UIViewControllerTransitioningDelegate

extension DrawerController: UIViewControllerTransitioningDelegate {
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerPresentationAnimator()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerDismissionAnimator()
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        let interactivePresenter = DrawerPresentationInteractiveTransition()
        interactivePresenter.wantsInteractiveStart = interactiveOpening
        self.interactivePresenter = interactivePresenter
        return interactivePresenter
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        let interactiveDismission = DrawerDismissionInteractiveTransition()
        interactiveDismission.wantsInteractiveStart = interactiveClosing
        self.interactiveDismisser = interactiveDismission
        return interactiveDismission
    }
    
}
