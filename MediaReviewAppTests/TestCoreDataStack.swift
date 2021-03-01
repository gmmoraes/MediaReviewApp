//
//  TestCoreDataStack.swift
//  MediaReviewAppTests
//
//  Created by Gabriel Moraes on 22/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import CoreData
import XCTest
@testable import MediaReviewApp


class TestCoreDataStack:CoreDataStack {

    lazy var _persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MediaReviewApp")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        description.url = URL(fileURLWithPath: "/dev/null")
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
                                        
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    
    override var persistentContainer: NSPersistentContainer {
      get { return _persistentContainer }
      set { _persistentContainer = newValue }
    }
    
}
