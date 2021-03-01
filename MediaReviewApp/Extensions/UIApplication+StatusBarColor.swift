//
//  UIApplication+StatusBarColor.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 08/10/2020.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {

    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }

}
