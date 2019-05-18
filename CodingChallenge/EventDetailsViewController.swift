//
//  ViewController.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {
    
    weak var event: Event?
    
    @IBOutlet weak var titleLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.titleLabel?.text = self.event?.title
    }


}

