//
//  NetworkChecker.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 09/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import Network
import UIKit


protocol NetworkCheckObserver: class {
    func statusDidChange(status: NWPath.Status)
}

class NetworkChecker {

    struct NetworkChangeObservation {
        weak var observer: NetworkCheckObserver?
    }

    private var monitor = NWPathMonitor()
    private static let _sharedInstance = NetworkChecker()
    private var observations = [ObjectIdentifier: NetworkChangeObservation]()
    var currentStatus: NWPath.Status {
        get {
            return monitor.currentPath.status
        }
    }

    class func sharedInstance() -> NetworkChecker {
        return _sharedInstance
    }

    init() {
        monitor.pathUpdateHandler = { [unowned self] path in
            for (id, observations) in self.observations {

                guard let observer = observations.observer else {
                    self.observations.removeValue(forKey: id)
                    continue
                }

                DispatchQueue.main.async(execute: {
                    observer.statusDidChange(status: path.status)
                })
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    func addObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = NetworkChangeObservation(observer: observer)
    }

    func removeObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }

}
