//
//  AppData.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import Foundation
import SugarRecord

public class AppData {
    
    public static var shared = {
        return AppData()
    }()
    
    private init() {
        self.db = AppData.db()
    }
    
    public static func db() -> CoreDataDefaultStorage  {
        let store =  CoreDataStore.named("AppData.sql")
        let bundle = Bundle(for: AppData.self)
        let model = CoreDataObjectModel.merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }
    
    public var db:CoreDataDefaultStorage
    
    public func removeStore() throws {
        try? self.db.removeStore()
        self.db = AppData.db()
        _ = self.db.saveContext
    }
}
