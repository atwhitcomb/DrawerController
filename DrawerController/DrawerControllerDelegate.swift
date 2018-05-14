//
//  DrawerControllerDelegate.swift
//  DrawerController
//
//  Created by Moat 740 on 5/11/18.
//  Copyright © 2018 Andrew James Thomas Whitcomb. All rights reserved.
//

import Foundation

public protocol DrawerControllerDelegate: class {
    
    func drawerControllerShouldAllowInteractivePresenting(_ drawerController: DrawerController) -> Bool
    func drawerControllerShouldAllowInteractiveDismission(_ drawerController: DrawerController) -> Bool
    
}

extension DrawerControllerDelegate {
    
    func drawerControllerShouldAllowInteractivePresenting(_ drawerController: DrawerController) -> Bool {
        return true
    }
    
    func drawerControllerShouldAllowInteractiveDismission(_ drawerController: DrawerController) -> Bool {
        return true
    }
    
}
