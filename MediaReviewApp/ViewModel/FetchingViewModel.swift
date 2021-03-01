//
//  FetchingViewModel.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 06/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import Foundation
import CoreData

protocol FetchingViewModelDelegate {
    func insetItems(indexPath:IndexPath)
    func performUpdate()
    func filter()
}

class FetchingViewModel:NSObject {
    
    private var blockOperation = BlockOperation()
    var fetchedResultController: NSFetchedResultsController<NSManagedObject>?
    var filterfetchedResultController: NSFetchedResultsController<NSManagedObject>?
    var coreDataStack = CoreDataStack()
    var entityName:String = ""
    var dataProvider:DataProvider?
    var activeFilter:Bool = false
    var currentAdaptedVC:MediaAdapter?
    var delegate:FetchingViewModelDelegate?
    var type:MediaType
    
    init(type:MediaType) {
        self.type = type
        super.init()
        if type == .movies {
            dataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, configData: coreDataStack.movieConfigData)
            entityName = "Movie"
        }else if type == .series {
            dataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, configData: coreDataStack.serieConfigData)
            entityName = "Serie"
        }
        fetchedResultController = configureFetchedResultController(entityName: entityName)
        currentAdaptedVC = MediaAdapter(type: type,dataProvider: dataProvider!)
        
        convertData(){_ in }
    }
    
    func configureFetchedResultController(entityName:String,predicate:NSPredicate? = nil) ->NSFetchedResultsController<NSManagedObject>{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortId", ascending:true)]
        fetchRequest.returnsDistinctResults = true
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
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
    
    func startBlockOperation() {
        self.blockOperation.start()
    }
    
    func loadMoreData() {
        if !(self.dataProvider?.isLoading ?? false) {
            //self.dataProvider?.isLoading = true
            self.currentAdaptedVC?.getData()
        }
    }
    
    func filterData(userInfo: [AnyHashable : Any]){
        var titlePredicate:NSPredicate?
        var trailerPredicate:NSPredicate?
        var activePredicates:[NSPredicate] = []
        
        
        if let filterTrailer = userInfo["trailer"] as? Bool, filterTrailer == true {
            trailerPredicate = NSPredicate(format: "video_path != %@","")
            activePredicates.append(trailerPredicate!)
        }
        
        if let searchedWord = userInfo["searchText"] as? String,searchedWord != "" {
            if type == .series {
                titlePredicate = NSPredicate(format: "name CONTAINS %@",searchedWord)
            }else if type == .movies {
              titlePredicate = NSPredicate(format: "title CONTAINS %@",searchedWord)
            }
            activePredicates.append(titlePredicate!)
        }
        
        if activePredicates.count > 0 {
            let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: activePredicates)
            activeFilter = true
            
            //guard let insertedData = currentAdaptedVC?.loadMedia(withPredicates: predicateCompound) else {return}
            fetchedResultController?.fetchRequest.predicate = predicateCompound

            do {
                
                try fetchedResultController?.performFetch()
                
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            convertData(){_ in
                self.delegate?.filter()
            }
        }else {
            activeFilter = false
            fetchedResultController?.fetchRequest.predicate = nil

            do {
                
                try fetchedResultController?.performFetch()
                
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            convertData(){_ in
                self.delegate?.filter()
            }
        }
    }
    func convertData(completion: @escaping(NSFetchedResultsChangeType) -> ()){
        let type:NSFetchedResultsChangeType = .insert
        if let insertedData = currentAdaptedVC?.convertData(fetchedObjects:fetchedResultController?.fetchedObjects) {
            self.currentAdaptedVC?.mediaDataList = insertedData
        }
        
        completion(type)
    }
    
}
extension FetchingViewModel:NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.performUpdate()
    }
    
}
   
