//
//  HomeViewModel.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 06/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import Foundation
import CoreData


class HomeViewModel: NSObject,NSFetchedResultsControllerDelegate {
    
    var coreDataStack = CoreDataStack()
    var dataProvider: DataProvider?
    lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Genre")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: dataProvider!.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self

        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()

    
    override  init(){
        super.init()
        dataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, configData: coreDataStack.movieConfigData)
        dataProvider?.dataProviderDataSyncDelegate = self
        dataProvider?.getGenres()
    }

}


extension HomeViewModel: DataProviderDataSyncDelegate {
    
    func dataSyncEnded() {
        if let genres = fetchedResultsController.fetchedObjects as? [Genre] {
            if genres.count > 0 {
                coreDataStack.genres = genres
            }
        }
    }
}
