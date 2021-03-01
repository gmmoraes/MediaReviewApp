//
//  HomeViewController.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 26/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

class SearchManager {
    var searchedTerms:[String] = []
    static let shared = SearchManager()
}


class HomeViewController: UIViewController,Storyboarded {
  
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var trailerSwitch: UISwitch!
    var searchManager = SearchManager.shared
    var currentSearched:String = ""
    var searchDict:[String: Any] = [:]
    var viewModel:HomeViewModel = HomeViewModel()
    //var coordinator:HomeCoordinator?
    var coordinator:TabBarCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .backgroundColor
        configSearchIcon()
        trailerSwitch.addTarget(self, action: #selector(self.switchValueDidChange), for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MovieViewController {
            vc.delegate = self
        }
        if let vc = segue.destination as? SerieViewController {
            vc.delegate = self
        }
    }

    
    @objc func switchValueDidChange(sender:UISwitch!) {
        searchDict["trailer"] = sender.isOn
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("filterArray"), object: nil, userInfo: searchDict)
    }
    
    private func configSearchIcon(){
        if let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField,
            let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .white
        }
    }
    
    private func checkIndexInRange(arr:[String],index:Int) -> Bool {
        return index >= arr.startIndex && index < arr.endIndex
    }
    
    @objc func reload() {
        guard let searchText = searchBar.text else { return }
        currentSearched = searchText
        searchDict["searchText"] = searchText
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("filterArray"), object: nil, userInfo: searchDict)
    }

    
}
extension HomeViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
        self.perform(#selector(self.reload), with: nil, afterDelay: 0.5)
    }
}

extension HomeViewController:FetchingViewControllerDelegate{
    func mediaSelected(selectedMedia: MediaData?) {
        coordinator?.goToDetailsViewController(data: selectedMedia as AnyObject?)
    }
}
