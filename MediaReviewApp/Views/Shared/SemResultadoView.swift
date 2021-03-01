//
//  SemResultadoView.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 02/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class SemResultadoView: UIView {

    
    @IBOutlet var contentView: GlassView!
    @IBOutlet weak var semResultadoImgView: UIImageView!
    @IBOutlet weak var semResultadosLbl: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        let bundle = Bundle(for: SemResultadoView.self)
        bundle.loadNibNamed("SemResultadoView", owner: self, options: nil)
        fixInView(self, contentView: self.contentView)
        toggleSemResultado(shouldHide: true)
    }
    
    func toggleSemResultado(shouldHide:Bool){
        self.isHidden = shouldHide
        semResultadoImgView.isHidden = shouldHide
        semResultadosLbl.isHidden = shouldHide
    }
    
    func fixInView(_ container: UIView!,contentView:UIView) -> Void{
        contentView.translatesAutoresizingMaskIntoConstraints = false;
        contentView.frame = container.frame;
        container.addSubview(contentView);
        NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
