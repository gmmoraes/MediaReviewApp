//
//  MediaAdapter.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 06/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import CoreData
import UIKit


struct MediaData:Hashable{
    var genre_ids: [NSNumber]? = nil
    var id: Int32 = -100
    var last_modified: String? = nil
    var overview: String? = nil
    var popularity: Double = 0
    var poster_path: String? = nil
    var vote_average: Double = 0
    var vote_count: Int32 = -1000
    var favorited: Bool = false
    var img: Data? = nil
    var rec_id: [NSNumber]? = nil
    var release_date: String? = nil //Serie.first_air_date && movie.release_date
    var name: String? = nil //Serie.name && Movie.title
    var adult: Bool = false // movie only
    var page: Int32 = 0// movie only
    var videoPath:String = ""
    var type:MediaType

}

class MediaAdapter {
    
    private var object: NSManagedObject?
    var type:MediaType
    var dataProvider: DataProvider
    var mediaDataList:[MediaData] = []

    init(type: MediaType,dataProvider: DataProvider) {
        self.type = type
        self.dataProvider = dataProvider
    }
    
    private func configureMovieData(movie:Movie) -> MediaData{
        var mediaData = MediaData(type: .movies)
        mediaData.genre_ids = movie.genre_ids
        mediaData.id = movie.id
        mediaData.last_modified = movie.last_modified
        mediaData.overview = movie.overview
        mediaData.popularity = movie.popularity
        mediaData.poster_path = movie.poster_path
        mediaData.vote_average = movie.vote_average
        mediaData.vote_count = movie.vote_count
        mediaData.favorited = movie.favorited
        mediaData.img = movie.img
        mediaData.rec_id = movie.rec_id
        mediaData.release_date = movie.release_date
        mediaData.name = movie.title
        mediaData.rec_id = movie.rec_id
        mediaData.adult = movie.adult
        mediaData.page = movie.page
        mediaData.videoPath = movie.video_path ?? ""
 
        return mediaData
    }
    
    private func configureSerieData(serie:Serie) -> MediaData{
        var mediaData = MediaData(type: .series)
        mediaData.genre_ids = serie.genre_ids
        mediaData.id = serie.id
        mediaData.last_modified = serie.last_modified
        mediaData.overview = serie.overview
        mediaData.popularity = serie.popularity
        mediaData.poster_path = serie.poster_path
        mediaData.vote_average = serie.vote_average
        mediaData.vote_count = serie.vote_count
        mediaData.favorited = serie.favorited
        mediaData.img = serie.img
        mediaData.rec_id = serie.rec_id
        mediaData.release_date = serie.first_air_date
        mediaData.name = serie.name
        mediaData.rec_id = serie.rec_id
        mediaData.videoPath = serie.video_path ?? ""
        
        return mediaData
    }
    
    func getSectionName() -> String{
        var sectionName:String = ""
        if type == .movies {
            sectionName = "Movies"
        }else if type == .series {
            sectionName = "TV Series"
        }
        return sectionName
    }
    
    func getData(){
        if type == .movies {
            dataProvider.getMovies()
        }else if type == .series {
            dataProvider.getSeries()
        }
    }
    
    func getTotalAmountOfData(fetchedObjects: [NSManagedObject]?) ->Int{
        if let fetchedObjects = fetchedObjects {
            if type == .movies {
                return fetchedObjects.compactMap({ $0 as? Movie }).count
            }else if type == .series {
               return fetchedObjects.compactMap({ $0 as? Serie }).count
            }
        }
        
        return 0
    }
    
    func convertData(fetchedObjects: [NSManagedObject]?) ->[MediaData]{
        var mediaDataList:[MediaData] = []
        
        if type == .movies {
            let movies = fetchedObjects?.compactMap({ $0 as? Movie })
            movies?.forEach { movie in
                let mediaData = configureMovieData(movie: movie)
                mediaDataList.append(mediaData)
            }
        }else if type == .series {
            let series = fetchedObjects?.compactMap({ $0 as? Serie })
            series?.forEach { series in
                let mediaData = configureSerieData(serie: series)
                mediaDataList.append(mediaData)
            }
        }
        
        
        return mediaDataList
        
    }
    
    func convertAnyData(fetchedObject: Any?) -> MediaData{
        var mediaData:MediaData = MediaData(type: .movies)
        
        if type == .movies {
            if let movie = fetchedObject as? Movie{
                mediaData = configureMovieData(movie: movie)
            }
        }else if type == .series {
            mediaData.type = .series
            if let serie = fetchedObject as? Serie{
                mediaData = configureSerieData(serie: serie)
            }
        }
        
        
        return mediaData
        
    }
    
    func loadMedia(withPredicates:NSCompoundPredicate? = nil) ->[MediaData] {
        var mediaDataList:[MediaData] = []
        if self.type == .movies {
            let moviesList:[Movie] = dataProvider.loadData(predicate: withPredicates)
            mediaDataList = self.convertData(fetchedObjects: moviesList)
        }else {
            let serieList:[Serie] = dataProvider.loadData(predicate: withPredicates)
            mediaDataList = self.convertData(fetchedObjects: serieList)
        }
        
        return mediaDataList
    }
    
    func configureFetchedResultController(id:Int32?,dataProvider:DataProvider) ->NSFetchedResultsController<NSManagedObject>{
        let entityName = self.type == .movies ? "Movie":"Serie"
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending:true)]

        if let id = id {
            let predicate:NSPredicate = NSPredicate(format: "id == %i", id)
            fetchRequest.predicate = predicate
        }
        
        fetchRequest.returnsDistinctResults = true
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: dataProvider.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)

        return controller
    }
    func updateMedia(id:Int32,newVal:Any,key:String){
        let entityName = self.type == .movies ? "Movie":"Serie"
        dataProvider.updateMedia(entityName: entityName, id: id, newVal: newVal, key: key)
    }

}
