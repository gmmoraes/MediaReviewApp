//
//  TabBarCoordinator.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 11/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

class TabBarCoordinator: BaseCoordinator {
    
    override init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        self.navigationController = navigationController
    }
    
    override func start() {
        let vc = TabBarController.instantiate()
        vc.coordinator = self
        let firstViewController = HomeViewController.instantiate()
        firstViewController.coordinator = self
        firstViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "baseline_home_black_18"), selectedImage: UIImage(named: "baseline_home_black_18"))

        let secondViewController = MinhaListaViewController.instantiate()
        secondViewController.coordinator = self
        secondViewController.tabBarItem =  UITabBarItem(title: "My list", image: UIImage(named: "baseline_star_rate_black_18"), selectedImage: UIImage(named: "baseline_star_rate_black_18"))

        let tabBarList = [firstViewController, secondViewController]

        vc.viewControllers = tabBarList
        navigationController.pushViewController(vc, animated: true)
    }
    
    func notifyWillDisappear(){
        self.isCompleted?()
    }
    
    func goToDetailsViewController(data:AnyObject?) {
        let detailsCoordinator = DetailsCoordinator(navigationController: self.navigationController, data: data)
        self.store(coordinator: detailsCoordinator)
        detailsCoordinator.start()
        detailsCoordinator.isCompleted = { [weak self] in
            self?.free(coordinator: detailsCoordinator)
        }
    }
}
