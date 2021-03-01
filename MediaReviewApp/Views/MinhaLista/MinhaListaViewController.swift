//
//  MinhaListaViewController.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 05/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import UIKit
import CoreData

class MinhaListaViewController: UIViewController,Storyboarded {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var semResultadoView: SemResultadoView!
    
    private var favoritedMedias: [Any] = []
    var viewModel = MinhaListaViewModel()
    var coordinator:TabBarCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 1)
        layout.itemSize = CGSize(width: width / 3.1, height: height / 3.5)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 10
        //collectionView!.collectionViewLayout = layout
        self.collectionView.backgroundColor = .backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.changesToBeAdded() {
           self.collectionView.reloadData()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func checkAmountOfFiles(totalData: Int) {
        let shouldShow:Bool = totalData > 0
        collectionView.isHidden = !shouldShow
        semResultadoView.toggleSemResultado(shouldHide: shouldShow)
    }
}
extension MinhaListaViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let totalData = viewModel.getTotalData()
        checkAmountOfFiles(totalData: totalData)
        return viewModel.getCountMedias()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MinhaListaCollectionCell", for: indexPath) as? MinhaListaCollectionCell {

            if viewModel.getCountMedias() >= indexPath.row {
                cell.imageView.image = UIImage(data: viewModel.getImageDataFromIndexPath(indexPath:indexPath))
            }
            
            cell.imageView.contentMode = .scaleToFill
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
}

extension MinhaListaViewController:MinhaListaViewModelDelegate{
    func reloadData() {
        self.collectionView.reloadData()
    }
    
    
}
