//
//  SeriesModel.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 26/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation

struct SeriesInfo: MediaInfo {
    var page: Int
    var total_pages: Int
    let results: [SeriesModel]

}

struct SeriesModel: Codable {
    let id: Int
    let name: String
    let popularity: Double
    let vote_count: Int
    let vote_average: Double
    let overview: String
    let poster_path: String?
    let genre_ids: [Int]
    let first_air_date: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case popularity
        case vote_count
        case vote_average
        case overview
        case poster_path
        case genre_ids
        case first_air_date
    }
    
}
