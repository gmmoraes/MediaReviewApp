//
//  FavoritedMedia.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 27/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation

struct FavoritedMedia: Codable {
    var moviesId: Int32?
    var seriesId: Int32?
    var isFavorited: Bool
    
    enum CodingKeys: String, CodingKey {
        case moviesId
        case seriesId
        case isFavorited
    }
}
