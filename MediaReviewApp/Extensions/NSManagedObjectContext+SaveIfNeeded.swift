//
//  NSManagedObjectContext+SaveIfNeeded.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 03/10/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import CoreData
extension NSManagedObjectContext {

    /// Only performs a save if there are changes to commit.
    /// - Returns: `true` if a save was needed. Otherwise, `false`.
    @discardableResult public func saveIfNeeded() throws -> Bool {
        guard hasChanges else { return false }
        try save()
        return true
    }
}
