//
//  TabButton.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 26/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class TabButton: UIButton {
    
    var lineView = UIView()
    let normalTextColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1.0)
    
    @IBInspectable var lineViewBkColor: UIColor? {
        didSet {
            setup()
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            self.lineView.isHidden = !(isHighlighted)
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            self.lineView.isHidden = !(isSelected)
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        lineView = UIView(frame: CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 2))
        lineView.backgroundColor =  lineViewBkColor
        lineView.isHidden = true
        self.setTitleColor(normalTextColor, for: .normal)
        self.setTitleColor(.white, for: .selected)
        self.setTitleColor(.white, for: .highlighted)
        
        if !(lineView.isDescendant(of: self)) {
            self.addSubview(lineView)
        }
        
    }

}
