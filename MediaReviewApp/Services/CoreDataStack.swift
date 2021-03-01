//
//  CoreDataStack.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 03/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import CoreData

enum StorageType {
  case persistent, inMemory
}

class CoreDataStack {
    
    init() {}
    //static let shared = CoreDataStack()
    var movieConfigData = ApiConfigData(mediaType: .movies)
    var serieConfigData = ApiConfigData(mediaType: .series)
    var genres:[Genre] = []
    var selectedMovie:Movie?
    var selectedSerie:Serie?
    
    lazy var persistentContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "MediaReviewApp")
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
}


