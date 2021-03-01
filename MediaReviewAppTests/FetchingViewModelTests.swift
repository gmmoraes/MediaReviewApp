//
//  FetchingViewModelTests.swift
//  MediaReviewAppTests
//
//  Created by Gabriel Moraes on 22/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

import XCTest
import CoreData
@testable import MediaReviewApp


class FetchingViewModelTests: XCTestCase {
    
    var coreDataStack: CoreDataStack!
    var dataProvider:DataProvider!
    var notificationCenter: NotificationCenter!
    
    
    override func setUp() {
        super.setUp()
        coreDataStack = TestCoreDataStack()
        notificationCenter = NotificationCenter()
    }

    override func tearDown() {
        super.tearDown()
        flushData(context: coreDataStack.persistentContainer.viewContext, entityName: "Movie")
        flushData(context: coreDataStack.persistentContainer.viewContext, entityName: "Serie")
        flushData(context: coreDataStack.persistentContainer.viewContext, entityName: "Genre")
    }
    
    func initStubs(context:NSManagedObjectContext,entityName:String,amountOfData:Int32) {
            
        func insertMovies(adult: Bool,favorited: Bool,id: Int32,page: Int32,popularity: Double,sortId: Double,title: String?,vote_average: Double,vote_count: Int32 ){
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: context)
            obj.setValue(adult, forKey: "adult")
            obj.setValue(title, forKey: "title")
            obj.setValue(favorited, forKey: "favorited")
            obj.setValue(id, forKey: "id")
            obj.setValue(page, forKey: "page")
            obj.setValue(popularity, forKey: "popularity")
            obj.setValue(sortId, forKey: "sortId")
            obj.setValue(vote_average, forKey: "vote_average")
            obj.setValue(vote_count, forKey: "vote_count")
        }
        
        func insertSeries(name: String?,favorited: Bool,id: Int32,page: Int32,popularity: Double,sortId: Double,vote_average: Double,vote_count: Int32 ){
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Serie", into: context)
            
            obj.setValue(name, forKey: "name")
            obj.setValue(favorited, forKey: "favorited")
            obj.setValue(id, forKey: "id")
            obj.setValue(page, forKey: "page")
            obj.setValue(popularity, forKey: "popularity")
            obj.setValue(sortId, forKey: "sortId")
            obj.setValue(vote_average, forKey: "vote_average")
            obj.setValue(vote_count, forKey: "vote_count")
        }
        
        func insertGenre(id:Int32?,name:String?,last_modified: String?){
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Genre", into: context)
            obj.setValue(name, forKey: "name")
            obj.setValue(id, forKey: "id")
            obj.setValue(last_modified, forKey: "last_modified")
        }
        
        for n in 0..<amountOfData{
            if entityName == "Movie" {
                insertMovies(adult: true, favorited: false, id: n, page: n, popularity: Double(n), sortId: Double(n), title: "Movie Test \(n)", vote_average: Double(n), vote_count: n)
            }else if entityName == "Serie" {
                insertSeries(name: "Serie Test \(n)", favorited: false, id: n, page: n, popularity: Double(n), sortId: Double(n), vote_average: Double(n), vote_count: n)
                
            }else if entityName == "Genre" {
                insertGenre(id: n, name: "Genre \(n)", last_modified: "27/02/2021")
            }
        }

        do {
            try context.save()
        }  catch {
            print("create fakes error \(error)")
        }
            
    }
    
    func flushData(context:NSManagedObjectContext,entityName:String) {
            
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let objs = try! context.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            context.delete(obj)
        }
        try! context.save()

    }
    
    func configMedia(mediaType: MediaType) -> (Int32,DataProvider) {
        let randomInt = Int32.random(in: 0..<10)
        let enityName = mediaType == .movies ? "Movie":"Serie"
        let config = ApiConfigData(mediaType: mediaType)
        let sut:DataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer,configData:config)
        initStubs(context: coreDataStack.persistentContainer.viewContext, entityName: enityName, amountOfData: randomInt)
        return (randomInt,sut)
    }
    
    func test_fetch_all_Movies() {
        let (randomInt,sut) = configMedia(mediaType: .movies)
        let results:[Movie] = sut.loadData()
        print("Result: movies \(results.count) randomInt \(randomInt)")


        //Assert return five todo items
        XCTAssertEqual(results.count, Int(randomInt))
            
    }
    
    func test_fetch_all_Series() {
        let (randomInt,sut) = configMedia(mediaType: .series)
        let results:[Serie] = sut.loadData()
        print("Result: series \(results.count) randomInt \(randomInt)")

        //Assert return five todo items
        XCTAssertEqual(results.count, Int(randomInt))
            
    }
    
    func test_fetch_all_Genres() {
        let randomInt = Int32.random(in: 0..<10)
        let config = ApiConfigData(mediaType: .series)
        let sut:DataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer,configData:config)
        initStubs(context: coreDataStack.persistentContainer.viewContext, entityName: "Genre", amountOfData: randomInt)
        
        let results:[Genre] = sut.loadData()
        print("Result: genres \(results.count) randomInt \(randomInt)")

        //Assert return five todo items
        XCTAssertEqual(results.count, Int(randomInt))
            
    }
    
    func test_fetch_filtered_Movie(){
        let (_,sut) = configMedia(mediaType: .movies)
        let viewModel = MockFetchingViewModel(type: .movies, dt: sut, coreDataStack: coreDataStack)
        let fakeFilter = FakeFilter()
        let _ = ViewModelManager(viewModel: viewModel,notificationCenter: self.notificationCenter)
        let notificationExpectation = XCTNSNotificationExpectation(name: Notification.Name("FilterEnded"),
                                                                   object: nil,
                                                                   notificationCenter: notificationCenter)
        
        
        fakeFilter.notifyPredicate(key: "searchText", val: "Movie Test 0")
        
        
        wait(for: [notificationExpectation], timeout: 0.1)
    }
    
    func test_fetch_filtered_Serie(){
        let (_,sut) = configMedia(mediaType: .series)
        let viewModel = MockFetchingViewModel(type: .series, dt: sut, coreDataStack: coreDataStack)
        let fakeFilter = FakeFilter()
        let _ = ViewModelManager(viewModel: viewModel,notificationCenter: self.notificationCenter)
        let notificationExpectation = XCTNSNotificationExpectation(name: Notification.Name("FilterEnded"),
                                                                   object: nil,
                                                                   notificationCenter: notificationCenter)
        
        
        fakeFilter.notifyPredicate(key: "searchText", val: "Serie Test 0")
        
        
        wait(for: [notificationExpectation], timeout: 0.1)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
