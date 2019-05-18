//
//  AppDataSpec.swift
//  CodingChallengeTests
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import Quick
import Nimble
import SugarRecord
@testable import CodingChallenge

class AppDataSpec: QuickSpec {
    override func spec() {
        
        describe("AppData Tests") {
            
            beforeEach {
                do {
                    try AppData.shared.db.removeStore()
                }
                catch _ {
                    // There was an error in the operation
                }
                
            }
            
            context("Insert Tests") {
                
                it("Inserts a record") {
                    do {
                        try AppData.shared.db.operation { (context, save) throws -> Void in
                            let event: Event = try! context.create()
                            event.title = "Test Title"
                            save()
                        }
                    }
                    catch _ {
                        // There was an error in the operation
                    }
                    let events: [Event] = try! AppData.shared.db.fetch(FetchRequest<Event>())
                    expect(events.count).toEventually( equal(1) )
                }
                
            }
        }
        
    }
}
