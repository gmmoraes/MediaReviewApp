//
//  MockFetchingViewModel.swift
//  MediaReviewAppTests
//
//  Created by Gabriel Moraes on 28/02/21.
//  Copyright © 2021 Gabriel Moraes. All rights reserved.
//

//fileprivate protocol NSFetchedResultsControllerProtocol {
//     func convertData(completion: @escaping(NSFetchedResultsChangeType) -> ())
//}

import CoreData
@testable import MediaReviewApp

class MockFetchingViewModel:FetchingViewModel{

    private var _coreDataStack:CoreDataStack
    private var _dataProvider:DataProvider

    override var coreDataStack: CoreDataStack {
      get { return _coreDataStack }
      set { _coreDataStack = newValue }
    }

    override var dataProvider: DataProvider? {
      get { return _dataProvider }
      set { _dataProvider = newValue! }
    }

    init(type:MediaType,dt:DataProvider,coreDataStack:CoreDataStack){
        self._dataProvider = dt
        self._coreDataStack = coreDataStack
        super.init(type: type)
    }

}

protocol FakeFilterDelegate: class {
    func postData(data:[AnyHashable: Any])
}

class FakeFilter {
    
    init(){}
    
    weak var delegate:FakeFilterDelegate?
    
    func notifyPredicate(key:String,val:String){
        var searchDict: [String: Any] = [:]
        searchDict[key] = val
        delegate?.postData(data: searchDict)
        //NotificationCenter.default.post(name: Notification.Name("FakeFilter"), object: nil, userInfo: searchDict)
    }
}


class ViewModelManager {
    var viewModel: FetchingViewModel!
    var notificationCenter: NotificationCenter!
    let fakeFilter = FakeFilter()
    
    init (viewModel:FetchingViewModel,notificationCenter:NotificationCenter){
        self.viewModel = viewModel
        self.notificationCenter = notificationCenter
        self.viewModel.delegate = self
         NotificationCenter.default.addObserver(self, selector: #selector(filterData(_:)), name: Notification.Name("FakeFilter"), object: nil)
        fakeFilter.delegate = self
    }
    
    @objc func filterData(_ notification: NSNotification) {
        guard let notification = notification.userInfo else {return}
        viewModel?.filterData(userInfo: notification)
    }
    
    func postNotification(){
        notificationCenter.post(name: Notification.Name("FilterEnded"),object: self)
    }
}
extension ViewModelManager: FetchingViewModelDelegate{
    func insetItems(indexPath: IndexPath) {}
    
    func performUpdate() {}
    
    func filter() {
        if viewModel?.currentAdaptedVC?.mediaDataList.count ?? 0 > 0 {
            self.postNotification()
        }
    }
    
    
}

extension ViewModelManager: FakeFilterDelegate {
    func postData(data: [AnyHashable: Any]) {
        viewModel?.filterData(userInfo: data)
    }
    
    
}
