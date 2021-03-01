//
//  MediaVideo.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 08/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation

struct MediaVideoInfo: Codable {
    var id: Int?
    var results:[MediaVideoModel]
}

struct MediaVideoModel: Codable {
    let key: String
    let type:String
    
    enum CodingKeys: String, CodingKey {
        case key
        case type
    }
    
}
