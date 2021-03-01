//
//  VideoCollectionViewCell.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 26/09/2020.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

struct VideoThumbnailRequestInfo {
    let section: Int
    let id: Int
    let url: URL
}

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var title = UILabel()
    var overview: String?
    
    var thumbnailRequestInfo: VideoThumbnailRequestInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.image = UIImage(named: "placeholder")
        configureImages()
        title.alpha = 0.0

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(named: "placeholder")
        imageView.setNeedsLayout()
    }
    
    func configureImages(){
        imageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(imageView)
    }
    
    func addImg(img:UIImage?){
        imageView.image = img
        self.setNeedsLayout()
    }
}
