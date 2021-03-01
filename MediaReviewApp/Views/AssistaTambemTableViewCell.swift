//
//  AssistaTambemTableViewCell.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 05/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

class AssistaTambemTableViewCell:UITableViewCell{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var semResultadoView: SemResultadoView!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    
    var media:[RecommendMedia] = [] {
        didSet {
            if media.count > 0 {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.removeLoadingWheel), object: nil)
                self.perform(#selector(self.removeLoadingWheel), with: nil, afterDelay: 0.5)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.backgroundColor = .backgroundColor
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1)
        layout.itemSize = CGSize(width: width / 3.2, height: height / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        startLoadingWheel()
    }
    
    private func checkIndexInRange(arr:[Any],index:Int) -> Bool {
        return index >= arr.startIndex && index < arr.endIndex
    }
    
    private func startLoadingWheel(){
        if media.count < 1 {
            self.collectionView.isHidden = true
            loadingWheel.startAnimating()
            self.bringSubviewToFront(loadingWheel)
            self.setNeedsLayout()
       }
    }
    
    @objc func removeLoadingWheel(){
        self.loadingWheel.stopAnimating()
        if media.count > 0 {
            self.collectionView.isHidden = false
        }else {
            self.semResultadoView.toggleSemResultado(shouldHide: false)
        }
        collectionView.reloadData()
    }
    
    @objc private func removeLoadingWheelPromisse() {
       removeLoadingWheel()
    }
    
}
extension AssistaTambemTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as? VideoCollectionViewCell {
            
            if checkIndexInRange(arr: media, index: indexPath.row) {
                if let img = media[indexPath.row].img {
                    cell.imageView.image = UIImage(data: img)
                }
            }
            
            return cell
            
        }

        return UICollectionViewCell()

    }

}

