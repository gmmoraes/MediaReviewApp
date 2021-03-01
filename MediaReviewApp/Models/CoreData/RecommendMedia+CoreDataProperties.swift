//
//  RecommendMedia+CoreDataProperties.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 07/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//
//

import Foundation
import CoreData


extension RecommendMedia {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<RecommendMedia> {
        return NSFetchRequest<RecommendMedia>(entityName: "RecommendMedia")
    }

    @NSManaged public var id: Int32
    @NSManaged public var img: Data?
    @NSManaged public var last_modified: String?
    @NSManaged public var mediaId: Int32
    @NSManaged public var name: String?
    @NSManaged public var parentId: Int32
    @NSManaged public var poster_path: String?
    @NSManaged public var type: Int32

}
