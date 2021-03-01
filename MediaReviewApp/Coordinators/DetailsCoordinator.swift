//
//  DetailsCoordinator.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 07/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

class DetailsCoordinator: BaseCoordinator {

    var data: AnyObject?
    
    init(navigationController: UINavigationController,
        data: AnyObject?) {
        super.init(navigationController: navigationController)
        self.navigationController = navigationController
        self.data = data
    }
    
    override func start() {
        guard let data = data as? MediaData else {return}
        let vc = DetailsViewController.instantiate()
        let viewModel = DetailsViewModel(type: data.type, mediaId: data.id,videoPath: data.videoPath)
        vc.viewModel = viewModel
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func notifyWillDisappear(){
        self.isCompleted?()
    }
}
