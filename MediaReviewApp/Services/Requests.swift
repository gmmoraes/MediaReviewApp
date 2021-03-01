//  Request.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 27/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation

protocol Request {}

extension Request {
    func requestApi(apiUrl: String, queryItems: [URLQueryItem]? = nil, authorization: String? = nil, completion: @escaping (Data) -> () ){
        guard var urlComponents = URLComponents(string: apiUrl) else {return}

        if let paramsQueryItems = queryItems {
            urlComponents.queryItems = paramsQueryItems
        }

        guard let url = urlComponents.url else {return}
        
        var getRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)

        if let authorization = authorization {
          getRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
        }

        getRequest.httpMethod = "GET"
        getRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        getRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        

        URLSession.shared.dataTask(with: getRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil { print("GET Request: Communication error: \(error!)") }
            if data != nil {
                guard let jsonData = data else {return}
                completion(jsonData)
            } else {
                DispatchQueue.main.async(execute: {
                    print("Received empty response.")
                })
            }
        }).resume()
    }
    
}
