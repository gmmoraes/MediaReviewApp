//
//  MainCoordinator.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 06/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

class MainCoordinator: BaseCoordinator {
    
    override func start() {
        let vc = FakeSplashScreenViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }

    func configTabCoordinator() {
        let tabCoordinator = TabBarCoordinator(navigationController: self.navigationController)
        self.store(coordinator: tabCoordinator)
        tabCoordinator.start()
        tabCoordinator.isCompleted = { [weak self] in
            self?.free(coordinator: tabCoordinator)
        }
    }
    
    
}
