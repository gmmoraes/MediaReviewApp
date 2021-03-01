//
//  Genres.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 27/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation

struct GenresInfo: Codable {
    var genres:[GenresModel]
}

struct GenresModel: Codable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
}
