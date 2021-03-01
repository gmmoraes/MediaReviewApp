//
//  TabBarController.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 26/09/2020.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate,Storyboarded {
    
    var coordinator:TabBarCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = .red // .navbarBackgroundColor
        self.tabBar.barTintColor =  .navbarBackgroundColor
        self.tabBar.unselectedItemTintColor =  .unselectedTabBarIconColor
        //self.navigationController?.navigationBar.isTranslucent = false
        if let navbarFont = UIFont(name: "HelveticaNeue", size: 20) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font: navbarFont]
        }
        self.tabBar.tintColor =  .selectedTabBarIconColor
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.navigationItem.hidesBackButton = true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
