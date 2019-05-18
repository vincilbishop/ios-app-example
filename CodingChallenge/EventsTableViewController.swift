//
//  EventsTableViewController.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import UIKit
import SugarRecord

class EventsTableViewController: UITableViewController {
    
    var observable: RequestObservable<Event>!
    
    var events: [Event] = {
        return try! AppData.shared.db.fetch(FetchRequest<Event>())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        Event.getEvents()
        
        self.observable = AppData.shared.db.observable(request: FetchRequest<Event>().sorted(with: "title", ascending: true))
        self.observable.observe { changes in
            switch (changes) {
            case .initial(let objects):
                print("\(objects.count) objects in the database")
            case .update(let deletions, let insertions, let modifications):
                print("\(deletions.count) deleted | \(insertions.count) inserted | \(modifications.count) modified")
                self.tableView.reloadData()
            case .error(_):
                print("Something went wrong")
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell

        cell.event = self.events[indexPath.row]
        cell.titleTextLabel?.text = self.events[indexPath.row].title
        
        return cell
    }

    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! EventDetailsViewController
        let cell = sender as! EventTableViewCell
        vc.event = cell.event!
    }
    
}

