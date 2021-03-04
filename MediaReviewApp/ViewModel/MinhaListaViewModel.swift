//
//  MinhaListaViewModel.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 10/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import Foundation
import CoreData

protocol MinhaListaViewModelDelegate: class{
    func reloadData()
}

class MinhaListaViewModel:NSObject,NSFetchedResultsControllerDelegate {
    
    var coreDataStack = CoreDataStack()
    var dataProvider: DataProvider?
    var serieDataProvider: DataProvider?
    var movieFetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    var serieFetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    var medias:[Data] = []
    weak var delegate: MinhaListaViewModelDelegate?
    private var changesPending: Bool = false
    
    override init() {
        super.init()
        configureControllers()
    }
    
    func configureControllers(){
        let mediaApiConfigData = ApiConfigData(mediaType: .movies)
        dataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, configData: mediaApiConfigData)
        let serieApiConfigData = ApiConfigData(mediaType: .series)
        serieDataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, configData: serieApiConfigData)
        
        movieFetchedResultsController = configureFetchedResultController(entityName: "Movie", customDataProvider: dataProvider)
        serieFetchedResultsController = configureFetchedResultController(entityName: "Serie", customDataProvider: serieDataProvider)
        
        
        movieFetchedResultsController?.fetchedObjects?.compactMap({ $0 as? Movie }).forEach {movie in
            if let img = movie.img {
                medias.append(img)
            }
        }
        
        serieFetchedResultsController?.fetchedObjects?.compactMap({ $0 as? Serie}).forEach {serie in
            if let img = serie.img {
                medias.append(img)
            }
        }
        
        delegate?.reloadData()
    }
    
    private func modifyData(anObject: Any,addition: Bool) {
        var newImg: Data?
        if let obj = anObject as? Serie {
            if let img = obj.img {
                newImg = img
            }
        }else if let obj = anObject as? Movie {
            if let img = obj.img {
                newImg = img
            }
        }
        
        if let newImg = newImg {
            if addition {
                medias.append(newImg)
            }else {
                medias = medias.filter { $0 != newImg}
            }
            self.changesPending = true
        }
    }
    
    func configureFetchedResultController(entityName:String,customDataProvider: DataProvider?) ->NSFetchedResultsController<NSManagedObject>{
        let predicate:NSPredicate = NSPredicate(format: "favorited == %@", NSNumber(value:true))
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending:true)]
        fetchRequest.predicate = predicate
        fetchRequest.returnsDistinctResults = true
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: customDataProvider!.viewContext,
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
            modifyData(anObject: anObject, addition: true)
        case .delete:
            modifyData(anObject: anObject, addition: false)
        default:
            break
        }
    }
    
}

extension MinhaListaViewModel {
    
    func getTotalData() -> Int {
        return (movieFetchedResultsController?.fetchedObjects?.count ?? 0) + (serieFetchedResultsController?.fetchedObjects?.count ?? 0)
    }
    
    func getCountMedias() -> Int {
        return medias.count
    }
    
    
    func getImageDataFromIndexPath(indexPath: IndexPath) -> Data {
        return medias[indexPath.row]
    }
    
    func changesToBeAdded() -> Bool {
        let tempChangesPending = changesPending
        changesPending = false
        return tempChangesPending
    }
}
