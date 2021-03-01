//
//  MediaInfo.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 26/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation

public protocol MediaInfo:Codable {
    var page: Int { get set }
    var total_pages: Int { get set }
}
