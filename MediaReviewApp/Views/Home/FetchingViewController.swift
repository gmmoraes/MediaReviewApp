//
//  FetchingViewController.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 04/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol FetchingViewControllerDelegate{
    func mediaSelected(selectedMedia: MediaData?)
}

class FetchingViewController: UIViewController,Storyboarded {


    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var semResultadoView: SemResultadoView!
    
    var viewModel:FetchingViewModel?
    let fontMetrics = UIFontMetrics(forTextStyle: .body)
    private var safeAreaManager = SafeAreaManager()

    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    var delegate:FetchingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicator)
        activityIndicator.color = .white
        
        activityIndicator.leadingAnchor.constraint(equalTo: self.collectionView.trailingAnchor,constant: -40).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor).isActive = true
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(filterData(_:)), name: Notification.Name("filterArray"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func configSemResultadoView(shouldHide:Bool){
        semResultadoView.toggleSemResultado(shouldHide: !shouldHide)
        collectionView.isHidden = shouldHide
        self.view.bringSubviewToFront(semResultadoView)
        semResultadoView.setNeedsLayout()
        collectionView.setNeedsLayout()
    }
    
    func checkIndexInRange(arr:[String],index:Int) -> Bool {
        return index >= arr.startIndex && index < arr.endIndex
    }
    
    @objc func filterData(_ notification: NSNotification) {
        guard let notification = notification.userInfo else {return}
        viewModel?.filterData(userInfo: notification)
    }
    
}


extension FetchingViewController: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.currentAdaptedVC?.mediaDataList.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as! VideoCollectionViewCell
            if let mediaDataList = viewModel?.currentAdaptedVC?.mediaDataList, mediaDataList.count > 0{
            cell.title.text = mediaDataList[indexPath.row].name
            if let img = mediaDataList[indexPath.row].img {
                cell.addImg(img: UIImage(data: img))
            }else {
                cell.addImg(img: UIImage(named: "placeholder"))
            }
            cell.overview = mediaDataList[indexPath.row].overview
            
        }

        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.30, height: self.view.frame.height * 0.70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMedia = viewModel?.currentAdaptedVC?.mediaDataList[indexPath.row]
        delegate?.mediaSelected(selectedMedia: selectedMedia)
    }


}
extension FetchingViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {

        if viewModel?.activeFilter == false,viewModel?.dataProvider?.isLoading == false{
            viewModel?.loadMoreData()
        }
        
        if viewModel?.dataProvider?.isLoading == true && (viewModel?.currentAdaptedVC?.mediaDataList.count ?? 0 >= (indexPaths.last?.row ?? 0 - 4)) &&  (viewModel?.currentAdaptedVC?.mediaDataList.count ?? 0 <= (indexPaths.last?.row ?? 0)) {
            activityIndicator.startAnimating()
        }else{
          activityIndicator.stopAnimating()
        }
 
    }
}



extension FetchingViewController:FetchingViewModelDelegate {
    func insetItems(indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.collectionView?.insertItems(at: [indexPath])
            self.collectionView?.setNeedsLayout()
            sleep(UInt32(0.1))
        }
    }
    
    func performUpdate() {
        collectionView?.performBatchUpdates({
            viewModel?.startBlockOperation()
        }, completion: nil)
    }
    
    func filter() {
        let shouldHide = viewModel?.currentAdaptedVC?.mediaDataList.count ?? 0 == 0
        configSemResultadoView(shouldHide: shouldHide)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.setNeedsLayout()
        }
    }
    
    
}
