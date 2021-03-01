//
//  Array+dif.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 05/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit
extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
