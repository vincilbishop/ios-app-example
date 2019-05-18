//
//  Context+Extension.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import Foundation
import CoreData
import SugarRecord

extension Context {
    public func managedObjectContext() -> NSManagedObjectContext {
        return self as! NSManagedObjectContext
    }
}
