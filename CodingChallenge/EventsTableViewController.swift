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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.showsCancelButton = true
        self.searchController.searchBar.searchBarStyle = .default
        self.searchController.searchBar.barStyle = .default
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.searchController.dismiss(animated: false, completion: nil)
    }
    
    // MARK: Search
    func updateFetch(_ query: String?, _ updateFromApi: Bool = false) {
        
        guard let queryString = query else {
            return
        }
        
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
        } else {
            self.events = []
            self.tableView.reloadData()
        }
    }
    
    // MARK: UITableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell

        cell.configureWithEvent(self.events[indexPath.row])
        
        return cell
    }

    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! EventDetailsViewController
        let cell = sender as! EventTableViewCell
        vc.event = cell.event!
    }
    
}

