//
//  EventsTableViewController.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import UIKit
import SugarRecord

class EventsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var observable: RequestObservable<Event>!
    var fetchRequest: FetchRequest<Event>!
    let searchController = UISearchController(searchResultsController: nil)
    
    var events: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.showsCancelButton = true

        self.tableView.tableHeaderView = searchController.searchBar
        self.searchController.searchResultsUpdater = self
        // Do any additional setup after loading the view.
        // Event.getEvents("Texas Rangers")
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchController.dismiss(animated: false, completion: nil)
    }
    
    // MARK: Search
    func updateFetch(_ query: String?, _ updateFromApi: Bool = false) {
        
        guard let queryString = query else {
            return
        }
        
        // Debounce
        
        // Update Local Fetch Request
        self.fetchRequest = FetchRequest<Event>().filtered(with: NSPredicate(format: "title CONTAINS[cd] %@", queryString)).sorted(with: "datetime_local", ascending: true)
        self.events = try! AppData.shared.db.fetch(self.fetchRequest)
        self.observable = AppData.shared.db.observable(request: self.fetchRequest)
        self.observable.observe { changes in
            switch (changes) {
            case .initial( _):
                self.tableView.reloadData()
            case .update( _, _, _):
                self.tableView.reloadData()
            case .error( _):
                return
            }
        }
        // Update from API
        if (updateFromApi) {
            Event.getEvents(queryString)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            self.updateFetch(searchText, true)
        }
    }
    
    // MARK: UITableView
    
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

