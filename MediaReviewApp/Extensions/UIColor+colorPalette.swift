//
//  UIColor+colorPalette.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 08/10/2020.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    @nonobjc class var backgroundColor: UIColor {
      return UIColor(red: 31.0/255.0, green: 31.0/255.0, blue: 31.0/255.0, alpha: 1)
    }
    
    @nonobjc class var navbarBackgroundColor: UIColor {
      return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    @nonobjc class var unselectedTabBarIconColor: UIColor {
        return UIColor(red: 103.0/255.0, green: 103.0/255.0, blue: 103.0/255.0, alpha: 1)
    }
    
    @nonobjc class var selectedTabBarIconColor: UIColor {
        return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
}
