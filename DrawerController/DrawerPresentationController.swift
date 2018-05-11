//
//  DrawerPresentationController.swift
//  DrawerController
//
//  Created by Andrew James Whitcomb on 5/9/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit

class DrawerPresentationController: UIPresentationController {
    
    lazy var dimmingView: UIView = {
        [unowned self] in
        var dimmingView = UIView(frame: self.containerView?.bounds ?? CGRect.zero)
        dimmingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        return dimmingView
    }()
    
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
        
        dimmingView.alpha = 0
        self.containerView?.addSubview(dimmingView)
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { [unowned self] (context) in
            self.dimmingView.alpha = 1
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { [unowned self] (context) in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }
    
}
