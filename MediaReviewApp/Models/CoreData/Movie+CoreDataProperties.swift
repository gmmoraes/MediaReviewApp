//
//  Movie+CoreDataProperties.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 07/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var adult: Bool
    @NSManaged public var favorited: Bool
    @NSManaged public var genre_ids: [NSNumber]?
    @NSManaged public var id: Int32
    @NSManaged public var img: Data?
    @NSManaged public var last_modified: String?
    @NSManaged public var overview: String?
    @NSManaged public var page: Int32
    @NSManaged public var popularity: Double
    @NSManaged public var poster_path: String?
    @NSManaged public var rec_id: [NSNumber]?
    @NSManaged public var release_date: String?
    @NSManaged public var sortId: Double
    @NSManaged public var title: String?
    @NSManaged public var video_path: String?
    @NSManaged public var vote_average: Double
    @NSManaged public var vote_count: Int32

}
