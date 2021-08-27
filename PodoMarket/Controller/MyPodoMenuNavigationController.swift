//
//  MyPodoMenuNavigationController.swift
//  PodoMarket
//
//  Created by TJ on 18/09/2019.
//  Copyright © 2019 zool2. All rights reserved.
//

import UIKit
import SideMenu

class MyPodoMenuNavigationController: UISideMenuNavigationController {
    
//    원래 사용 했던 SideMenuNavigationController
    let customSideMenuManager = SideMenuManager()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sideMenuManager = customSideMenuManager
        sideMenuManager.menuPresentMode = .viewSlideOutMenuIn
        
        appDelegate.myPodoMenu = self
    }
}
//func myAlert(_ title: String, message: String) {
//    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
//    let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
//    alert.addAction(action)
//    self.present(alert, animated: true, completion: nil)
//}
