//
//  EventSpec.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import OHHTTPStubs
import Quick
import Nimble
import SugarRecord
@testable import CodingChallenge

class EventSpec: QuickSpec {
    override func spec() {

        describe("an Event") {
            beforeEach {
                try! AppData.shared.db.removeStore()
            }
            
            context("Network Operations") {
                beforeEach {
                   OHHTTPStubs.mockAppResponses()
                }
                
                it("gets events") {
                    var actual: [Event] = try! AppData.shared.db.fetch(FetchRequest<Event>())
                    expect(actual.count).to( equal(0) )
                    
                    Event.getEvents("Texas Rangers")
                    
                    expect{
                        actual = try! AppData.shared.db.fetch(FetchRequest<Event>())
                        return actual.count
                        }.toEventually( beGreaterThan(0))
                }
                
                it("maps properties correctly") {
                    var items: [Event] = try! AppData.shared.db.fetch(FetchRequest<Event>())
                    expect(items.count).to( equal(0) )
                    Nimble.AsyncDefaults.Timeout = 5
                    waitUntil { done in
                        Event.getEvents("Texas Rangers", { (response) in
                            
                            items = try! AppData.shared.db.fetch(FetchRequest<Event>())
                            expect(items.count).to(beGreaterThan(0))
                            expect(items.first).toNot(beNil())
                            if let actual = items.first {
                                expect(actual.title).to(beAnInstanceOf(String.self))
                                expect(actual.identifier).to(beAnInstanceOf(Int64.self))
                                expect(actual.identifier).to(beGreaterThan(0))
                                expect(actual.venue_name).to(beAnInstanceOf(String.self))
                                expect(actual.performers).toNot(beNil())
                                expect(actual.performers?.count).to(beGreaterThan(0))
                                
                                // Must give CoreData a change to lazy load the value else will be nil on unwrap
                                let performersSet = actual.performers!
                                let performers: [Performer] = performersSet.array as! [Performer]
                                expect(performers.first!.imageUrlString).to(beAnInstanceOf(String.self))
                            }
                            
                            done()
                        })
                    }
                }
                
                it("does not duplicate identifiers") {
                    var actual: [Event] = try! AppData.shared.db.fetch(FetchRequest<Event>())
                    expect(actual.count).to( equal(0) )
                    
                    waitUntil { done in
                        Event.getEvents("Texas Rangers", { (response) in
                            
                            actual = try! AppData.shared.db.fetch(FetchRequest<Event>())
                            expect(actual.count).to( equal(10) )
                            
                            Event.getEvents("Texas Rangers",  { (response) in
                                
                                actual = try! AppData.shared.db.fetch(FetchRequest<Event>())
                                expect(actual.count).to( equal(10) )
                                
                                Event.getEvents("Texas Rangers", { (response) in
                                    
                                    actual = try! AppData.shared.db.fetch(FetchRequest<Event>())
                                    expect(actual.count).to( equal(10) )
                                    
                                    done()
                                })
                            })
                            
                        })
                    }
                }
            }
        }
        
    }
}
