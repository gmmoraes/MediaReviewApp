//
//  FakeSplashScreenViewController.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 08/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

class FakeSplashScreenViewController:UIViewController,Storyboarded{
    
    let viewModel:FakeSplashScreenViewModel = FakeSplashScreenViewModel()
    var coordinator:MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "032541")
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkIfCanGoHome()
    }
    
    
    func goToHome(){
        //performSegue(withIdentifier: "goToHomeSegue", sender: nil)
        //coordinator?.goToHome(data: nil)
        coordinator?.configTabCoordinator()
    }

}

extension FakeSplashScreenViewController:FakeSplashScreenViewModelDelegate {
    func goHome() {
        DispatchQueue.main.async {
            self.goToHome()
        }
    }
    func showErrorMsg(){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error", message: "There was a problem with your conection", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel, handler: { action in
                self.goToHome()
            })
            alertController.addAction(okAction)

            self.present(alertController, animated: true,completion:nil)
        }
    }
}
