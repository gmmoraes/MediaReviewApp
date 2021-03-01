//
//  FakeSplashScreenViewModel.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 06/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import Foundation
import CoreData
import Network

protocol FakeSplashScreenViewModelDelegate{
    func goHome()
    func showErrorMsg()
}

class FakeSplashScreenViewModel:NSObject,NSFetchedResultsControllerDelegate {

    var movieFetchedResultController: NSFetchedResultsController<NSManagedObject>?
    var serieFetchedResultController: NSFetchedResultsController<NSManagedObject>?
    var genreFetchedResultController: NSFetchedResultsController<NSManagedObject>?
    //var coreDataStack = CoreDataStack.shared
    var coreDataStack:CoreDataStack = CoreDataStack()
    var networkCheck = NetworkChecker.sharedInstance()
    var movieDataProvider:DataProvider
    var serieDataProvider:DataProvider
    var genreDataProvider:DataProvider
    
    var shouldGoHome:Bool = false
    var delegate:FakeSplashScreenViewModelDelegate?
    
    override init() {
        movieDataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, configData: coreDataStack.movieConfigData)
        serieDataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, configData: coreDataStack.serieConfigData)
        genreDataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, configData: coreDataStack.movieConfigData)
        super.init()
        
        movieFetchedResultController = configureFetchedResultController(entityName: "Movie", dataProvider: movieDataProvider)
        serieFetchedResultController = configureFetchedResultController(entityName: "Serie", dataProvider: serieDataProvider)
         genreFetchedResultController = configureFetchedResultController(entityName: "Genre", dataProvider: genreDataProvider)
        
        
        movieDataProvider.getMovies()
        serieDataProvider.getSeries()
        genreDataProvider.getGenres()
    }
    
    func configureFetchedResultController(entityName:String,dataProvider: DataProvider?) ->NSFetchedResultsController<NSManagedObject>{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:entityName)
        let sortKey = entityName == "Genre" ? "id" : "sortId"
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending:true)]
        
        fetchRequest.returnsDistinctResults = true
        
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
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.checkIfCanGoHome()
        case .update:
            self.checkIfCanGoHome()
        default:
            break
        }
    }
    
    func checkIfCanGoHome(){
        
        //networkCheck
        if networkCheck.currentStatus == .satisfied{
            if self.movieFetchedResultController?.fetchedObjects?.count ?? 0 > 0 && self.serieFetchedResultController?.fetchedObjects?.count ?? 0 > 0 && self.genreFetchedResultController?.fetchedObjects?.count ?? 0 > 0 && self.shouldGoHome == false{
                self.shouldGoHome = true
                delegate?.goHome()
            }
        }else {
            delegate?.showErrorMsg()
        }

    }
}

extension FakeSplashScreenViewModel:NetworkCheckObserver {
    func statusDidChange(status: NWPath.Status) {
       self.checkIfCanGoHome()
    }
}
