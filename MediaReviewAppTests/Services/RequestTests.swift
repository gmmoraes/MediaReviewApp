//
//  RequestTests.swift
//  MediaReviewAppTests
//
//  Created by Gabriel Moraes on 21/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import XCTest
@testable import MediaReviewApp

fileprivate protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol

}
extension URLSession: URLSessionProtocol {
    fileprivate func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}

fileprivate protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }

fileprivate class MockURLSession:Request {
    private (set) var lastURL: String?
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextError: Error?

    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = request.url?.absoluteString
        completionHandler(nextData, nil, nextError)
        return nextDataTask
    }
}


fileprivate protocol Request:URLSessionProtocol {}

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

        dataTask(with: getRequest, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                completion(data)
            }
        }).resume()
    }
    
}

fileprivate class HttpClient {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    private let session: URLSessionProtocol
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func get( urlStr: String,queryItems: [URLQueryItem], callback: @escaping DataTaskResult ) {
        guard let session = session as? MockURLSession else {return}
        session.requestApi(apiUrl: urlStr, queryItems: queryItems, authorization: nil){ (resultObject) -> () in
            callback(resultObject, nil, nil)
        }
    }
}


fileprivate class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false

    func resume() {
        resumeWasCalled = true
    }
}




class RequestTests: XCTestCase {
    
    fileprivate var httpClient: HttpClient!
    fileprivate let session = MockURLSession()
    override func setUp() {
        httpClient = HttpClient(session: session)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_get_request_withURL(){
        let apiKey = "xxxxxxxxxxxx"
        let lang = "en-US"
        let queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: lang),
        ]
        let url = "https://api.themoviedb.org/3/movie/popular"
        let finalURL = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=\(lang)"

        httpClient.get(urlStr: url, queryItems: queryItems){ (_, _, _) in}
        
        // Assert
        XCTAssert(session.lastURL == finalURL)
    }
    
    func test_check_behaviour() {
        let apiKey = "xxxxxxxxxxxx"
        let lang = "en-US"
        let queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: lang),
        ]
        let url = "https://api.themoviedb.org/3/movie/popular"
        let dataTask = MockURLSessionDataTask()
        session.nextDataTask = dataTask
        
         httpClient.get(urlStr: url, queryItems: queryItems){ (_, _, _) in}

        XCTAssert(dataTask.resumeWasCalled)
    }
    
    func test_GET_WithResponseData_ReturnsTheData() {
        let apiKey = "xxxxxxxxxxxx"
        let lang = "en-US"
        let queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: lang),
        ]
        let url = "https://api.themoviedb.org/3/movie/popular"
        let expectedData = "{}".data(using: .utf8)
        session.nextData = expectedData

        var actualData: Data?
        httpClient.get(urlStr: url, queryItems: queryItems) { (data, _, _)  in
            actualData = data
        }

        XCTAssertEqual(actualData, expectedData)
    }
    

    
//    func test_get_data() {
//        let expectation = self.expectation(description: "fetching")
//        var data:Data?
//        let apiKey = "xxxxxxxxxxxx"
//        let lang = "en-US"
//        let queryItems = [
//            URLQueryItem(name: "api_key", value: apiKey),
//            URLQueryItem(name: "language", value: lang),
//        ]
//        let url = "https://api.themoviedb.org/3/movie/popular"
//        let dataTask = MockURLSessionDataTask()
//        session.nextDataTask = dataTask
//
//         httpClient.get(urlStr: url, queryItems: queryItems){ (dataFetched,resp,error) in
//
//            if let dataFetched = dataFetched {
//                data = dataFetched
//                expectation.fulfill()
//            }
//
//
//        }
//        waitForExpectations(timeout: 7, handler: nil)
//        XCTAssert(data != nil)
//    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
