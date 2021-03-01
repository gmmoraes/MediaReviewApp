//
//  MediaInfoTableViewCell.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 25/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit


protocol MediaInfoCellMessager {
    func returnPressed()
    func AdicionarEmMinhaLista(id:Int32,favoritado:Bool)
    func playVideo(videoID:String)
}

class MediaInfoTableViewCell:UITableViewCell{
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var mediaPosterView: UIImageView!
    @IBOutlet weak var tituloLbl: UILabel!
    @IBOutlet weak var tipoLbl: UILabel!
    @IBOutlet weak var descricao: UITextView!
    
    @IBOutlet weak var assistaBtn: BorderButton!
    @IBOutlet weak var minhaListaBtn: BorderButton!
    @IBOutlet weak var returnButton: UIButton!
    
    var delegate:MediaInfoCellMessager?
    var mediaId:Int32 = -1000
    var videoId:String?
    var tipo: MediaType?
    private let starImg = UIImage(named: "baseline_star_rate_black_24")?.withRenderingMode(.alwaysTemplate)
    private let checkImg = UIImage(named: "baseline_check_black_24")?.withRenderingMode(.alwaysTemplate)
    private let playImg = UIImage(named: "baseline_play_arrow_black_24")?.withRenderingMode(.alwaysTemplate)
    private let returnImg = UIImage(named: "baseline_arrow_back_black_24")?.withRenderingMode(.alwaysTemplate)
    private let unelectedTintColor = UIColor(hexString: "#CDCDCD")
    private let selectedTintColor = UIColor(hexString: "#454545")
    private let borderBtnDisableColor = UIColor(hexString: "#666666")
    private let borderBtnNormalColor = UIColor(hexString: "#CDCDCD")

    override func awakeFromNib() {
        super.awakeFromNib()
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImageView.addSubview(blurEffectView)
        backgroundImageView.contentMode = .scaleToFill

        assistaBtn.setImage(playImg , for: .normal)
        assistaBtn.setTitleColor(borderBtnDisableColor, for: .disabled)
        minhaListaBtn.setTitleColor(borderBtnDisableColor, for: .disabled)
        returnButton.setImage(returnImg , for: .normal)
        minhaListaBtn.imageView?.isUserInteractionEnabled = true
        minhaListaBtn.addTarget(self, action: #selector(AdicionarEmMinhaLista(_:)), for: .touchUpInside)
  
        
        if let returnBtnIcon = returnButton.imageView {
            returnBtnIcon.tintColor = .white
        }

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mediaId = -1000
        videoId = nil
    }
    
    
    func resize(withWidth newWidth: CGFloat, img:UIImage) -> UIImage? {
        let scale = newWidth / img.size.width
        let newHeight = img.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        img.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    @IBAction func returnPressed(_ sender: UIButton) {
        delegate?.returnPressed()
    }
    
    
    @objc func AdicionarEmMinhaLista(_ gesture: UITapGestureRecognizer) {
        minhaListaBtn.setSelected(minhaListaBtn.isSelected)
        delegate?.AdicionarEmMinhaLista(id: mediaId,favoritado:minhaListaBtn.isSelected)
        
        
        configMinhaListaBtn(favoritado: minhaListaBtn.isSelected, enabled: minhaListaBtn.isEnabled)
        
    }
    
    
    @IBAction func playVideo(_ sender: BorderButton) {
        if let videoId = videoId {
          delegate?.playVideo(videoID: videoId)
        }
    }
    
    
    func configYoutubeVideo(canPlayVideo:Bool){
        assistaBtn.isEnabled = canPlayVideo
        assistaBtn.isUserInteractionEnabled = canPlayVideo
        let color = canPlayVideo ? borderBtnNormalColor:borderBtnDisableColor
        assistaBtn.borderColor = color
        if let assistaBtnImg = assistaBtn.imageView {
              assistaBtnImg.tintColor = color
          }
        assistaBtn.setNeedsLayout()
    }
    
    func configMinhaListaBtn(favoritado:Bool, enabled:Bool){
        minhaListaBtn.isEnabled = enabled
        minhaListaBtn.isUserInteractionEnabled = enabled
        let color = enabled ? borderBtnNormalColor:borderBtnDisableColor
        let bkColor = favoritado ? unelectedTintColor:.clear
        let textColor = favoritado ? selectedTintColor:unelectedTintColor
        let state:UIControl.State = favoritado ? .selected:.normal
        let texto = favoritado ? "Added" : "Favorites"
        let img = favoritado ? checkImg: starImg
        minhaListaBtn.borderColor = color
        minhaListaBtn.backgroundColor = bkColor
        minhaListaBtn.setTitleColor(textColor, for: state)
        minhaListaBtn.setTitle(texto, for: state)
        minhaListaBtn.setImage(img , for: state)
        if let minhaLista = minhaListaBtn.imageView {
            minhaLista.tintColor = textColor
        }
        
        minhaListaBtn.setNeedsLayout()

    }
    
    
}
