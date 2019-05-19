//
//  String+Date.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/19/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import Foundation
import SwiftDate

extension String {
    public func toPrettyDateString() -> String {
        return self.toDate()!.toFormat("E, d MMM yyyy HH:mm a")
    }
}
