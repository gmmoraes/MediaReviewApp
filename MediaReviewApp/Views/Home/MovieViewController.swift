//
//  MovieViewController.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 26/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MovieViewController: FetchingViewController {
    
    var shouldReloadCollectionView:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FetchingViewModel(type: .movies)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}



