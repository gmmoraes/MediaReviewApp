//
//  SerieViewController.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 26/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SerieViewController: FetchingViewController {
    
    var popularSeries: [Serie] = []
    var filteredSeries:[Serie] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FetchingViewModel(type: .series)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}


