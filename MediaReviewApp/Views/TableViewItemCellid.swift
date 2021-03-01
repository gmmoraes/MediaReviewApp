////
////  TableViewItemCellid.swift
////  MediaReviewApp
////
////  Created by Gabriel Moraes on 26/09/20.
////  Copyright © 2020 Gabriel Moraes. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//protocol CellDelegate {
//    func colCategorySelected(_ movies: Movie?, series: Serie?, image: UIImage)
//    func loadMoreData(currentSection:Int)
//    func cellIsLoaded(section:Int)
//}
//
//class HomeTableViewCell: UITableViewCell {
//    
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var semResultadosLbl: UILabel!
//    @IBOutlet weak var semResultadoView: GlassView!
//    @IBOutlet weak var semResultadoImgView: UIImageView!
//    
//    var numberOfCells: Int = 0
//    var isLoading = false
//    var tableViewHeight:CGFloat = 0
//    var tableViewWidth:CGFloat = 0
//
//    
//    var popularMovies: [Movie] = []{
//        didSet{
//            toggleSemResultado(shouldHide:popularMovies.count > 0)
//        }
//    }
//    var popularSeries: [Serie] = [] {
//        didSet {
//          toggleSemResultado(shouldHide:popularSeries.count > 0)
//        }
//    }
//    var currentSection: Int = 0{
//        didSet{
//            delegate?.cellIsLoaded(section:currentSection)
//        }
//    }
//    var delegate : CellDelegate?
//    
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.collectionView.delegate = self
//        self.collectionView.dataSource = self
//        collectionView.backgroundColor = .backgroundColor
//        collectionView.reloadData()
//        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(userHasTap(_:)))
//        tap.numberOfTapsRequired = 1
//        tap.numberOfTouchesRequired = 1
//        tap.delegate = self
//        collectionView?.addGestureRecognizer(tap)
//    }
//    
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    
//    private func toggleSemResultado(shouldHide:Bool){
//        semResultadoView.isHidden = shouldHide
//        semResultadoImgView.isHidden = shouldHide
//        semResultadosLbl.isHidden = shouldHide
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetX = scrollView.contentOffset.x
//
//        let loadOnScrollThresholdX = CGFloat(1500)
//        if (offsetX > scrollView.contentSize.width - loadOnScrollThresholdX) {
//            delegate?.loadMoreData(currentSection: self.currentSection)
//        }
//    }
//    
//    @objc func userHasTap(_ sender: UITapGestureRecognizer) {
//
//        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
//            if let cell = self.collectionView?.cellForItem(at: indexPath) as? VideoCollectionViewCell, let text = cell.title.text, let image =  cell.imageView.image, let overview = cell.overview {
//
//                if cell.tag == 0 {
//                    delegate?.colCategorySelected(popularMovies[indexPath.row], series: nil, image: image)
//                }else if cell.tag == 1 {
//                    delegate?.colCategorySelected(nil, series: popularSeries[indexPath.row], image: image)
//                }
//            }
//            print("you can do something with the cell or index path here \(indexPath)")
//        } else {
//            print("collection view was tapped")
//        }
//    }
//
//}
//
//
//
//extension HomeTableViewCell: UICollectionViewDataSource {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return numberOfCells
//    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as! VideoCollectionViewCell
//        
//        cell.tag = currentSection
//        cell.title.text = currentSection == 0 ? popularMovies[indexPath.row].title : popularSeries[indexPath.row].name
//        cell.overview = currentSection == 0 ? popularMovies[indexPath.row].overview : popularSeries[indexPath.row].overview
//        
//        if  (popularMovies.count > 0 || popularSeries.count > 0) {
//            let posterPath = currentSection == 0 ? popularMovies[indexPath.row].poster_path : popularSeries[indexPath.row].poster_path
//            let id = currentSection == 0 ? Int(popularMovies[indexPath.row].id) : Int(popularSeries[indexPath.row].id)
//            if let posterPath = posterPath, let urlPath = URL(string: "https://image.tmdb.org/t/p/w185/" + posterPath) {
//                cell.thumbnailRequestInfo = VideoThumbnailRequestInfo(section: currentSection, id: id, url: urlPath)
//            }
//        }
//        
//        return cell
//
//    }
//
//}
//
//extension HomeTableViewCell: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: tableViewWidth * 0.30, height: tableViewHeight)
//    }
//
//}
