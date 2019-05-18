//
//  EventTableViewCell.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import Foundation
import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextLabel: UILabel?
    weak var event: Event?
    
}
