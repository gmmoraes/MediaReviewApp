//
//  TheMovieDbApiRequest.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 27/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation


struct ApiConfigData{
    let urlString:String
    let customID:String
    let mediaType:MediaType
    let apiKey:String
    let firtLang:String
    var fetchedPages:[Int] = []
    var pageInProgress:[Int] = []
    var imgDatas:[Int32:Data] = [:]
    var hasVideo:Bool = false
    
    init(mediaType:MediaType) {
        self.mediaType = mediaType
        self.urlString = mediaType == .movies ? "https://api.themoviedb.org/3/movie/popular":"https://api.themoviedb.org/3/tv/popular"
        self.apiKey = "825389946ad345f364dea4bbb7293e10"
        self.firtLang = "en-US"
        self.customID = ""
    }
    
    init(mediaType:MediaType,customID:String,hasVideo:Bool) {
        self.mediaType = mediaType
        self.customID = customID
        self.apiKey = "825389946ad345f364dea4bbb7293e10"
        
        if mediaType == .movies {
            if hasVideo {
                 self.urlString =  "https://api.themoviedb.org/3/movie/" + customID + "/videos"
            }else {
               self.urlString =  "https://api.themoviedb.org/3/movie/" + customID + "/recommendations"
            }
        } else if mediaType == .series {
            if hasVideo {
                 self.urlString =  "https://api.themoviedb.org/3/tv/" + customID + "/videos"
            }else {
              self.urlString =  "https://api.themoviedb.org/3/tv/" + customID + "/recommendations"
            }
        }else {
            self.urlString =  ""
        }
        self.firtLang = "en-US"
        
    }
    
    init(urlString: String, mediaType:MediaType, apiKey:String,firtLang:String,customID:String) {
        self.mediaType = mediaType
        self.urlString = urlString
        self.apiKey = apiKey
        self.firtLang = firtLang
        self.customID = customID
    }
    
    mutating func updateFetchedPages(page:Int){
        fetchedPages.append(page)
    }
    
    func getNextPage() -> Int {
        let sortedPage = fetchedPages.sorted()
        for page in sortedPage {
            if !(sortedPage.contains(page)) && !(sortedPage.contains(page)) {
                return page
            }
        }
        let nextPg = (sortedPage.last ?? 0) + 1
        if !(sortedPage.contains(nextPg)){
            return nextPg
        }
        
        return 0
        //
    }
    
    func configData(manuallySectPage: Int? = nil) -> [URLQueryItem]{
        let nextPage = getNextPage()
        var stringNextPage = String(nextPage)
        if let manuallySectPage = manuallySectPage {
            stringNextPage = String(manuallySectPage)
        }
        let queryItems = [
            URLQueryItem(name: "api_key", value: self.apiKey),
            URLQueryItem(name: "language", value: self.firtLang),
            URLQueryItem(name: "page", value: stringNextPage)
        ]
        
        return queryItems
    }
    
    func configUrl(pageNumber:Int) -> String{
        return urlString + "?api_key=" + apiKey + "&language=en-US&page=" + String(pageNumber)
    }
    
    mutating func updatePageInProgress(pageToRemove:Int){
        self.pageInProgress = pageInProgress.filter { $0 != pageToRemove }
    }

}

protocol TheMovieDbApiRequest:Request {}

extension TheMovieDbApiRequest {

    func getGenreList(movieConfigData: ApiConfigData, completion: @escaping (GenresInfo) -> () ){
        let queryItems = [
            URLQueryItem(name: "api_key", value: movieConfigData.apiKey),
            URLQueryItem(name: "language", value: movieConfigData.firtLang),
        ]
        requestApi(apiUrl: "https://api.themoviedb.org/3/genre/movie/list", queryItems: queryItems, authorization: nil){ (resultObject) -> () in
            let jsonDecoder = JSONDecoder()
            do {
                let response = try jsonDecoder.decode(GenresInfo.self, from: resultObject)
                completion(response)
                
            } catch {
                DispatchQueue.main.async(execute: {
                    print("Unable to parse JSON response")
                    print(error)
                })
            }
        }
        
    }
    
    func getData<T:Codable>(manuallySectPage: Int? = nil, configData: ApiConfigData, customQueryItems:[URLQueryItem]? = nil, completion: @escaping (T) -> () ){
        let queryItems = customQueryItems != nil ? customQueryItems!:configData.configData(manuallySectPage: manuallySectPage)
        
        requestApi(apiUrl: configData.urlString, queryItems: queryItems, authorization: nil){ (resultObject) -> () in
            let jsonDecoder = JSONDecoder()
            do {
                let response = try jsonDecoder.decode(T.self, from: resultObject)
                completion(response)
                
            } catch {
                DispatchQueue.main.async(execute: {
                    print("Unable to parse JSON response")
                    print(error)
                })
            }
        }
    }
}

