//
//  DataProvider.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 03/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol DataProviderDelegate{}

protocol DataProviderDataSyncDelegate:DataProviderDelegate{
    func dataSyncEnded()
}

protocol DataProviderVideoDelegate:DataProviderDelegate{
    func trailerVideoFetchEnded(videoPath:String?)
}


final class DataProvider:TheMovieDbApiRequest,ImageManager {
    
    
    var configData:ApiConfigData
    private let persistentContainer: NSPersistentContainer
    var errorHandler: (Error) -> Void = {_ in }
    var isLoading:Bool = false
    var dataProviderDataSyncDelegate:DataProviderDataSyncDelegate?
    var dataProviderVideoDelegate:DataProviderVideoDelegate?
    var predicate:NSPredicate?
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    init(persistentContainer: NSPersistentContainer,configData:ApiConfigData) {
        self.persistentContainer = persistentContainer
        self.configData = configData
    }
    
    
    func getMediaTrailer(mediaId:Int32,mediaType:MediaType) {
        let videoMovieApiConfigData = ApiConfigData(mediaType: mediaType, customID: String(mediaId),hasVideo: true)
        let queryItems = [
            URLQueryItem(name: "api_key", value: configData.apiKey),
            URLQueryItem(name: "language", value: configData.firtLang),
        ]
   
        self.getData(configData: videoMovieApiConfigData,customQueryItems: queryItems) {[weak self] (response:MediaVideoInfo) -> () in
            let lastMovieVideo = response.results.last
            let trailer = response.results.filter({$0.type == "Trailer"}).first
            if let trailer = trailer {
                self?.dataProviderVideoDelegate?.trailerVideoFetchEnded(videoPath:trailer.key)
            }else if let lastMovieVideo = lastMovieVideo {
                self?.dataProviderVideoDelegate?.trailerVideoFetchEnded(videoPath:lastMovieVideo.key)
            }
            
        }
    }
    
    func fetchMedia<T:MediaInfo>(manuallySectPage: Int? = nil,configData: ApiConfigData,customQueryItems:[URLQueryItem]? = nil, completion: @escaping (T) -> () ){
        let nextpage = self.configData.getNextPage()
        self.configData.pageInProgress.append(nextpage)
        DispatchQueue.global().async {
            self.getData(manuallySectPage:manuallySectPage, configData: configData,customQueryItems:customQueryItems) {[weak self] (response:T) -> () in
                self?.configData.updatePageInProgress(pageToRemove: response.page)
                self?.configData.updateFetchedPages(page: response.page)
                let taskContext = self?.persistentContainer.newBackgroundContext()
                taskContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext?.undoManager = nil
                completion(response)
            }
        }
    }
    
    
    func getRecommendMovies(manuallySectPage: Int? = nil,movieConfigData: ApiConfigData) {
        self.fetchMedia(manuallySectPage: manuallySectPage, configData: movieConfigData) {[weak self] (response:MoviesInfo)  in
            if let id = Int32(movieConfigData.customID){
                self?.synchronizeRecommendMovies(movies: response.results, parentId: id, taskContext: (self?.persistentContainer.newBackgroundContext())!)
            }
        }
    }
    
    func getRecommendSeries(manuallySectPage: Int? = nil,seriesConfigData: ApiConfigData) {
        self.fetchMedia(manuallySectPage: manuallySectPage, configData: seriesConfigData) {[weak self] (response:SeriesInfo)  in
            if let id = Int32(seriesConfigData.customID){
                self?.synchronizeRecommendSeries(series: response.results, parentId: id,taskContext: (self?.persistentContainer.newBackgroundContext())!)
            }
        }
    }
    
    func getMovies(manuallySectPage: Int? = nil) {
        self.fetchMedia(manuallySectPage: manuallySectPage, configData: self.configData) {[weak self] (response:MoviesInfo)  in
            self?.synchronizeMovies(movies: response.results, page: response.page, taskContext: (self?.persistentContainer.newBackgroundContext())!)
        }
    }
    
    func getSeries(manuallySectPage: Int? = nil) {
        self.fetchMedia(manuallySectPage: manuallySectPage, configData: self.configData) {[weak self] (response:SeriesInfo)  in
            self?.synchronizeSeries(series: response.results, page: response.page, taskContext: (self?.persistentContainer.newBackgroundContext())!)
        }
    }

    
    func getGenres(manuallySectPage: Int? = nil) {
        getGenreList(movieConfigData: configData) {[weak self] (response) -> () in
            let taskContext = self?.persistentContainer.newBackgroundContext()
            taskContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext?.undoManager = nil
            self?.synchronizeGenres(genres: response.genres, taskContext: taskContext!)
        }
    }
    
    func updateMedia(entityName:String,id:Int32,newVal:Any,key:String){
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        fetchRequest.predicate = NSPredicate(format:"id == %i", id)
        
        do {
            guard let results = try context.fetch(fetchRequest) as? [NSManagedObject] else {return}
            if results.count != 0 { // Atleast one was returned
                results[0].setValue(newVal, forKey: key)
            }
            
        } catch {
            print("Fetch Failed: \(error)")
        }
        
        do {
            try context.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    
    
    private func someEntityExists(id: Int32,mediaId:String? = nil, entityName:String,taskContext: NSManagedObjectContext) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        if let mediaId = mediaId {
            fetchRequest.predicate = NSPredicate(format: "mediaId = %i", mediaId)
        }else {
            fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        }
        
        
        var result: NSManagedObject?
        
        do {
            result = try taskContext.fetch(fetchRequest).last
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return result
    }
    
    private func synchronizeMovies(movies: [MoviesModel],page:Int, taskContext: NSManagedObjectContext) {
        var moviesFetched:[Movie] = []
        var movie:Movie?
        var totalAmountOfMoviesFetched:Int = 0
        taskContext.performAndWait {
            let today = self.getStringFiedDate()
            
            for modelData in movies {
                totalAmountOfMoviesFetched += 1
                if let existingMovie = self.someEntityExists(id: Int32(modelData.id), entityName:"Movie",taskContext: taskContext) as? Movie{
                    movie = existingMovie
                }else if let newMovie = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: taskContext) as? Movie{
                    movie = newMovie
                }
                
                
                if let movie = movie, movie.last_modified != today {
                    self.isLoading = true
                    let stringFiedPage = String(page)
                    if let indexPosition = movies.firstIndex(where: {$0.id == Int(modelData.id)}) {
                        let stringFiedId = String(indexPosition)
                        let stringFiedSortId = stringFiedPage + "." + stringFiedId + String(modelData.id)
                        movie.sortId = (stringFiedSortId as NSString).doubleValue
                        movie.page = Int32(page)
                        movie.id = Int32(modelData.id)
                        movie.title = modelData.title
                        movie.popularity = modelData.popularity
                        movie.vote_count = Int32(modelData.vote_count)
                        movie.vote_average = modelData.vote_average
                        movie.overview = modelData.overview
                        movie.poster_path = modelData.poster_path
                        movie.adult = modelData.adult
                        let formattedGenreIds = modelData.genre_ids.map({(id:Int) -> NSNumber in
                            return NSNumber(value: id)
                        })
                        movie.genre_ids = formattedGenreIds
                        movie.release_date = modelData.release_date
                        let date = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy"
                        let stringDate = dateFormatter.string(from: date)
                        movie.last_modified = stringDate
                        movie.favorited = false
                        let imgUrlPath = "https://image.tmdb.org/t/p/w185/" + (modelData.poster_path ?? "")
                        self.fetchImage(id:Int32(modelData.id), urlPath:imgUrlPath,completion: { (data) -> Void in
                            movie.img = data
                            moviesFetched.append(movie)
                            self.updateMedia(entityName:"Movie",id: movie.id, newVal: movie.img as Any, key: "img")
                        })
                        if taskContext.hasChanges {
                            do {
                                try taskContext.save()
                            } catch {
                                print("Error: \(error)\nCould not save Core Data context.")
                            }
                            taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
                        }
                        self.isLoading = false
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    private func synchronizeSeries(series: [SeriesModel],page:Int, taskContext: NSManagedObjectContext) {
        var seriesFetched:[Serie] = []
        var totalAmountOfSeriesFetched:Int = 0
        var serie:Serie?
        taskContext.performAndWait {
            let today = self.getStringFiedDate()
            for modelData in series {
                totalAmountOfSeriesFetched += 1
                if let existingSerie = self.someEntityExists(id: Int32(modelData.id), entityName:"Serie",taskContext: taskContext) as? Serie{
                    serie = existingSerie
                }else if let newSerie = NSEntityDescription.insertNewObject(forEntityName: "Serie", into: taskContext) as? Serie{
                    serie = newSerie
                }
                
                
                if let serie = serie, serie.last_modified != today {
                    self.isLoading = true
                    let stringFiedPage = String(page)
                    if let indexPosition = series.firstIndex(where: {$0.id == Int(modelData.id)}) {
                        let stringFiedId = String(indexPosition)
                        let stringFiedSortId = stringFiedPage + "." + stringFiedId + String(modelData.id)
                        serie.sortId = (stringFiedSortId as NSString).doubleValue
                        serie.page = Int32(page)
                        serie.id = Int32(modelData.id)
                        serie.first_air_date = modelData.first_air_date
                        serie.last_modified = self.getStringFiedDate()
                        serie.name = modelData.name
                        serie.overview = modelData.overview
                        serie.popularity = modelData.popularity
                        serie.poster_path = modelData.poster_path
                        serie.vote_count = Int32(modelData.vote_count)
                        serie.vote_average = modelData.vote_average
                        let formattedGenreIds = modelData.genre_ids.map({(id:Int) -> NSNumber in
                            return NSNumber(value: id)
                        })
                        serie.genre_ids = formattedGenreIds
                        let date = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy"
                        let stringDate = dateFormatter.string(from: date)
                        serie.last_modified = stringDate
                        serie.favorited = false
                        let imgUrlPath = "https://image.tmdb.org/t/p/w185/" + (modelData.poster_path ?? "" )
                        self.fetchImage(id:Int32(modelData.id), urlPath:imgUrlPath,completion: { (data) -> Void in
                            serie.img = data
                            seriesFetched.append(serie)
                            if taskContext.hasChanges {
                                do {
                                    try taskContext.save()
                                    self.dataProviderDataSyncDelegate?.dataSyncEnded()
                                } catch {
                                    print("Error: \(error)\nCould not save Core Data context.")
                                }
                                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
                            }
                            self.isLoading = false
                        })
                        
                    }
                    
                    
                    
                }
                
            }
            
        }
        
    }
    
    private func synchronizeRecommendMovies(movies: [MoviesModel],parentId:Int32, taskContext: NSManagedObjectContext) {
        var mediasFetched:[RecommendMedia] = []
        var media:RecommendMedia?
        taskContext.perform {
            let today = self.getStringFiedDate()
            
            for modelData in movies {
                if let existingMedia = self.someEntityExists(id: Int32(modelData.id), entityName:"RecommendMedia",taskContext: taskContext) as? RecommendMedia{
                    media = existingMedia
                }else if let nenewMedia = NSEntityDescription.insertNewObject(forEntityName: "RecommendMedia", into: taskContext) as? RecommendMedia{
                    media = nenewMedia
                }
                
                
                if let media = media, media.last_modified != today {
                    self.isLoading = true
                    media.id = Int32(modelData.id)
                    media.mediaId = 20000 + Int32(modelData.id)
                    media.name = modelData.title
                    media.poster_path = modelData.poster_path
                    media.parentId = parentId
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    let stringDate = dateFormatter.string(from: date)
                    media.last_modified = stringDate
                    
                    let imgUrlPath = "https://image.tmdb.org/t/p/w185/" + (modelData.poster_path ?? "")
                    self.fetchImage(id:Int32(modelData.id), urlPath:imgUrlPath,completion: { (data) -> Void in
                        media.img = data
                        mediasFetched.append(media)

                        self.updateMedia(entityName: "RecommendMedia", id: media.id, newVal: media.img as Any, key: "img")
                    })
                    
                    if taskContext.hasChanges {
                        do {
                            try taskContext.save()
                        } catch {
                            print("Error: \(error)\nCould not save Core Data context.")
                        }
                        taskContext.reset()
                    }
                    self.isLoading = false
                    
                }
            }
            
        }
    }
    private func synchronizeRecommendSeries(series: [SeriesModel],parentId:Int32, taskContext: NSManagedObjectContext) {
        var mediasFetched:[RecommendMedia] = []
        var media:RecommendMedia?
        taskContext.perform {
            let today = self.getStringFiedDate()
            
            for modelData in series {
                if let existingMedia = self.someEntityExists(id: Int32(modelData.id), entityName:"RecommendMedia",taskContext: taskContext) as? RecommendMedia{
                    media = existingMedia
                }else if let nenewMedia = NSEntityDescription.insertNewObject(forEntityName: "RecommendMedia", into: taskContext) as? RecommendMedia{
                    media = nenewMedia
                }
                
                
                if let media = media, media.last_modified != today {
                    self.isLoading = true
                    media.id = Int32(modelData.id)
                    media.mediaId = 10000 + Int32(modelData.id)
                    media.name = modelData.name
                    media.poster_path = modelData.poster_path
                    media.parentId = parentId
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    let stringDate = dateFormatter.string(from: date)
                    media.last_modified = stringDate
                    
                    let imgUrlPath = "https://image.tmdb.org/t/p/w185/" + (modelData.poster_path ?? "")
                    self.fetchImage(id:Int32(modelData.id), urlPath:imgUrlPath,completion: { (data) -> Void in
                        media.img = data
                        mediasFetched.append(media)
                        self.updateMedia(entityName: "RecommendMedia", id: media.id, newVal: media.img as Any, key: "img")
                    })
                    
                    if taskContext.hasChanges {
                        do {
                            try taskContext.save()
                        } catch {
                            print("Error: \(error)\nCould not save Core Data context.")
                        }
                        taskContext.reset()
                    }
                    self.isLoading = false
                    
                }
            }
            
        }
    }
    
    private func synchronizeGenres(genres: [GenresModel], taskContext: NSManagedObjectContext) {
        var genre:Genre?
        var totalAmountOfGenresFetched:Int = 0
        taskContext.perform {
            let today = self.getStringFiedDate()
            for modelData in genres {
                totalAmountOfGenresFetched += 1
                if let existingGenre = self.someEntityExists(id: Int32(modelData.id), entityName:"Genre",taskContext: taskContext) as? Genre{
                    genre = existingGenre
                }else if let newGenre = NSEntityDescription.insertNewObject(forEntityName: "Genre", into: taskContext) as? Genre{
                    genre = newGenre
                }
                
                if let genre = genre, genre.last_modified != today {
                    genre.id = Int32(modelData.id)
                    genre.name = modelData.name
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    let stringDate = dateFormatter.string(from: date)
                    genre.last_modified = stringDate
                    if taskContext.hasChanges {
                        do {
                            try taskContext.save()
                        } catch {
                            print("Error: \(error)\nCould not save Core Data context.")
                        }
                        taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
                    }
                }else{
                    self.loadGenre()
                }
                
            }
            
        }
        
    }
    
    private func getStringFiedDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let stringDate = dateFormatter.string(from: date)
        return stringDate
    }
    
    
    func fetchImage(id:Int32, urlPath:String,completion: @escaping(Data) -> ()){
        if let urlPath = URL(string: urlPath) {
            self.loadVideoThumbnail(url: urlPath){ dataList in
                if let data = dataList[0] as? Data{
                    completion(data)
                }
                
            }
        }
    }
    
    func loadData<T:NSManagedObject>(predicate: NSPredicate? = nil) ->[T]{
        var datas:[T] = []
        let context = self.backgroundContext
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName:String(describing: T.self), in: context)
        request.entity = entity
        request.returnsDistinctResults = true
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            try datas = context.fetch(request) as! [T]
        } catch {
            print("Fetch Failed: \(error)")
        }
        
        return datas
    }
    
    func loadGenre(predicate: NSPredicate? = nil){
        let context = self.persistentContainer.newBackgroundContext() //appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Genre", in: context)
        request.entity = entity
        request.returnsDistinctResults = true
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            try context.fetch(request)
        } catch {
            print("Fetch Failed: \(error)")
        }
        dataProviderDataSyncDelegate?.dataSyncEnded()
    }
    
}
