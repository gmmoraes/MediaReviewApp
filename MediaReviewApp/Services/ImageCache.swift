//
//  ImageCache.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 27/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

enum MediaType {
    case series
    case movies
    case relatedMovies
    case relatedSeries
}

protocol ImageManager:class {}

extension ImageManager {
    
    func loadVideoThumbnail(url: URL, completionHandler:@escaping (_ data:[Any]) -> Void) {
            if let data = try? Data(contentsOf: url) {
                var dataToReturn:[Any] = []
                dataToReturn.append(data)
                dataToReturn.append(url.path)
                completionHandler(dataToReturn)
            }
    }
    
}

class ImageCache {
    
    static let shared = ImageCache()
    
    func loadVideoThumbnail(thumbnailRequestInfo: VideoThumbnailRequestInfo, completionHandler:@escaping (_ image:UIImage) -> Void) {
        let mappedName = String(thumbnailRequestInfo.id)
        
        let currentMediaType:MediaType = thumbnailRequestInfo.section ==  0 ? .movies:.series
        
        if let image = loadImageFromDiskWith(directoryType: currentMediaType, fileName: mappedName) {
            completionHandler(image)
            return
        }
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: thumbnailRequestInfo.url) {
                    if let image = UIImage(data: data) {
                        completionHandler(image)
                    }
                }
            }
        }
    
    
    func createDirectory(directoryType:MediaType){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        var dataPath: URL?
        switch directoryType {
        case .series:
            dataPath = docURL.appendingPathComponent("series")
        default:
            dataPath = docURL.appendingPathComponent("movies")
        }
        
        if let dataPath = dataPath, !FileManager.default.fileExists(atPath: dataPath.absoluteString){
            do {
                try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
    }
    

    func loadImageFromDiskWith(directoryType:MediaType, fileName: String) -> UIImage? {

        var imageUrl: URL?


        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

          let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
          let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            switch directoryType {
            case .series:
                imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent("series").appendingPathComponent(fileName)
            default:
                imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent("movies").appendingPathComponent(fileName)
            }
            
            if let imageUrl = imageUrl {
                let image = UIImage(contentsOfFile: imageUrl.path)
                return image
            }
        }

          return nil
      }
    



}
