//
//  DetailsViewModel.swift
//  MediaReviewApp 
//
//  Created by Gabriel Moraes on 07/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import Foundation
import CoreData
import Network

protocol DetailsViewModelDelegate: class {
    func reload()
    func update()
    func showErrorMsg()
}

class DetailsViewModel: NSObject {
    var networkCheck = NetworkChecker.sharedInstance()
    var isConnectedToInternet: Bool = true
    private var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    private var assistaTambemFetchedResultsController: NSFetchedResultsController<RecommendMedia>?
    var type:MediaType
    private var currentAdaptedVC: MediaAdapter?
    var currentObjec: NSManagedObject?
    private var coreDataStack = CoreDataStack()
    private var dataProvider: DataProvider?
    private var assistaTambemDataProvider: DataProvider?
    
    var mediaId: Int32
    var videoPath: String
    var titleText: String?
    var imgData: Data?
    var overview: String?
    var section: Int?
    var favoritado: Bool?
    
    weak var delegate: DetailsViewModelDelegate?
    
    init(type: MediaType,mediaId: Int32,videoPath: String) {
        self.type = type
        self.mediaId = mediaId
        self.videoPath = videoPath
        super.init()
        configureAdatper()
    }
    
    private func configureAssistaTambemFetchedResultController(id:Int32,dataProvider:DataProvider) ->NSFetchedResultsController<RecommendMedia>{
        let fetchRequest = NSFetchRequest<RecommendMedia>(entityName: "RecommendMedia")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mediaId", ascending: true)]
        
        fetchRequest.returnsDistinctResults = true
        fetchRequest.fetchLimit = 10
        let predicate: NSPredicate = NSPredicate(format: "parentId == %i", id)
        fetchRequest.predicate = predicate
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: dataProvider.viewContext,
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
    
    func configureAdatper(){
        
        let mediaApiConfigData = ApiConfigData(mediaType: self.type)
        dataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, configData: mediaApiConfigData)
        dataProvider?.dataProviderVideoDelegate = self
        
        let assistaTambemMediaApiConfigData = ApiConfigData(mediaType: type, customID: String(mediaId), hasVideo: false)
        assistaTambemDataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, configData: assistaTambemMediaApiConfigData)
        
        currentAdaptedVC = MediaAdapter(type: self.type,dataProvider: dataProvider!)
        fetchedResultsController = currentAdaptedVC?.configureFetchedResultController(id: mediaId, dataProvider: dataProvider!)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        assistaTambemFetchedResultsController = configureAssistaTambemFetchedResultController(id: mediaId,dataProvider: assistaTambemDataProvider!)
        
        configureData()
        if videoPath.isEmpty == true {
            dataProvider?.getMediaTrailer(mediaId: self.mediaId, mediaType: self.type)
        }
        
        if type == .movies {
            assistaTambemDataProvider?.getRecommendMovies(movieConfigData: assistaTambemMediaApiConfigData)
        }else if type == .series{
            assistaTambemDataProvider?.getRecommendSeries(seriesConfigData: assistaTambemMediaApiConfigData)
        }
        
        self.updateConnection()
    }
    
    func configureData(){
        if let media = currentAdaptedVC?.convertAnyData(fetchedObject: fetchedResultsController?.fetchedObjects?.last) {
            self.mediaId = media.id
            self.titleText = media.name
            self.overview = media.overview
            self.favoritado = media.favorited
            self.imgData = media.img
        }
    }
    
    func getGenres() -> String{
        var genres = ""
        if let mediaData = currentAdaptedVC?.convertData(fetchedObjects: fetchedResultsController?.fetchedObjects).last {
            mediaData.genre_ids?.forEach { genre in
                let movieGenteId = Int32(truncating: genre)
                if let index = coreDataStack.genres.firstIndex(where: { $0.id == movieGenteId }), let genreName = coreDataStack.genres[index].name {
                    let spacedGenre = genreName + ", "
                    genres += spacedGenre
                }
                
            }
        }
        
        return genres
        
    }
    
    func updateData(id: Int32,favorite: Bool){
        currentAdaptedVC?.updateMedia(id: id, newVal: favorite, key: "favorited")
    }
    
    @objc private func upateView() {
        delegate?.update()
    }
    
}

extension DetailsViewModel {
    func getMedia() -> Int32? {
        return mediaId
    }
    func getvideoPath() -> String? {
        return videoPath
    }
    func getTitle() -> String? {
        return titleText
    }
    func getImgData() -> Data? {
        return imgData
    }
    func getOverView() -> String? {
        return overview
    }
    func getSection() -> Int? {
        return section
    }
    func getFavoritado() -> Bool? {
        return favoritado
    }
    func getType() -> MediaType {
        return self.type
    }
    func getTypeSubLbl() -> String {
        let txt = type == .movies ? "Movie" : "Serie"
        return txt
    }
    
    func getRecommendMedia() -> [RecommendMedia]? {
        return assistaTambemFetchedResultsController?.fetchedObjects
    }
    
    func getMediaData() -> [MediaData]? {
          return currentAdaptedVC?.convertData(fetchedObjects: fetchedResultsController?.fetchedObjects)
      }
}

extension DetailsViewModel: NetworkCheckObserver {
    
    func statusDidChange(status: NWPath.Status) {
        updateConnection()
    }
    
    func updateConnection(){
        if networkCheck.currentStatus == .satisfied{
            self.isConnectedToInternet = true
        }else {
            self.isConnectedToInternet = false
            delegate?.showErrorMsg()
        }
        
    }
    
    
}

extension DetailsViewModel:NSFetchedResultsControllerDelegate{
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let _ = anObject as? RecommendMedia {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.upateView), object: nil)
                self.perform(#selector(self.upateView), with: nil, afterDelay: 0.75)
            }
        default:
            break
        }
    }
    
    
}

extension DetailsViewModel: DataProviderVideoDelegate{
    
    func trailerVideoFetchEnded(videoPath: String?) {
        if let videoPath = videoPath {
            self.videoPath = videoPath
            self.currentAdaptedVC?.updateMedia(id: self.mediaId, newVal: videoPath, key: "video_path")
            delegate?.reload()
        }
    }
    
    
}
