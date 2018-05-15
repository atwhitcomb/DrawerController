//
//  DrawerNavigationController.swift
//  DrawerControllerExample
//
//  Created by Andrew James Whitcomb on 5/13/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import UIKit
import DrawerController

class DrawerNavigationController: UINavigationController {

    var drawerBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Drawer", style: .plain, target: self, action: #selector(DrawerNavigationController.presentDrawer));
    var drawerViewController: UIViewController = {
        let drawerViewController = UIViewController(nibName: nil, bundle: nil)
        drawerViewController.view.backgroundColor = .blue
        drawerViewController.preferredContentSize = CGSize(width: 200, height: 0)
        return drawerViewController
    }()
    var drawerController: DrawerController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        drawerController = DrawerController(presentedViewController: drawerViewController, presenting: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewControllers.first?.navigationItem.leftBarButtonItem = drawerBarButtonItem
    }
    
    @objc func presentDrawer() {
        present(drawerViewController, animated: true, completion: nil)
    }
}
