//
//  DrawerControllerDelegate.swift
//  DrawerController
//
//  Created by Moat 740 on 5/11/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import Foundation

protocol DrawerControllerDelegate: class {
    
    func drawerControllerShouldAllowInteractivePresenting(_ drawerController: DrawerController) -> Bool
    func drawerControllerPresentationGestureBegan(_ drawerController: DrawerController)
    
    func drawerControllerShouldAllowInteractiveDismission(_ drawerController: DrawerController) -> Bool
    func drawerControllerDismissionGestureBegan(_ drawerController: DrawerController)
    
}

extension DrawerControllerDelegate {
    
    func drawerControllerShouldAllowInteractivePresenting(_ drawerController: DrawerController) -> Bool {
        return true
    }
    
    func drawerControllerShouldAllowInteractiveDismission(_ drawerController: DrawerController) -> Bool {
        return true
    }
    
}
