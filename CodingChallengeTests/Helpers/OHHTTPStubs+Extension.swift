//
//  OHHTTPStubs+Extension.swift
//  CodingChallengeTests
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import Foundation
import OHHTTPStubs
 // @testable import CodingChallenge

extension OHHTTPStubs {
    public static func mockAppResponses() {
    
        stub(condition: isHost("api.seatgeek.com")) { _ in
            // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
            let stubPath = OHPathForFile("EventsGet.json", EventSpec.self)
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
    }
}
