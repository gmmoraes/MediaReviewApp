//
//  BaseCoordinator.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 07/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

class BaseCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var isCompleted: (() -> ())?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {}
    
}
