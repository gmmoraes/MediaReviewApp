//
//  Genre+CoreDataProperties.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 27/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//
//

import Foundation
import CoreData


extension Genre {
    //Alterar o nome de fetchRequest -> createFetchRequest para evitar ambiguidade como método fetchRequest de NSManagedObject
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Genre> {
        return NSFetchRequest<Genre>(entityName: "Genre")
    }
    
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var last_modified: String?
    
}
