//
//  SafeAreaManager.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 30/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

struct SafeAreaManager {
    var topSafeArea: CGFloat = 0.0
    var bottomSafeArea: CGFloat = 0.0
    var safeAreHeight:CGFloat = 0.0
    
    mutating func updateSafeareaData(view:UIView){
        topSafeArea = view.safeAreaInsets.top
        bottomSafeArea = view.safeAreaInsets.bottom
    }
    
    mutating func updateDeprecatedOS(topVal:CGFloat, bottomVal:CGFloat){
        topSafeArea = topVal
        bottomSafeArea = bottomVal
    }
    
    mutating func calculateSafeAreHeight(viewHeight:CGFloat,navBarHeight:CGFloat){
       safeAreHeight = viewHeight - topSafeArea - bottomSafeArea -  navBarHeight
    }
}

