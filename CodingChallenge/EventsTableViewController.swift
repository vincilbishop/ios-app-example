//
//  EventsTableViewController.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import UIKit
import SugarRecord
import RxSwift
import RxCocoa

// class EventsTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
class EventsTableViewController: UITableViewController, UISearchBarDelegate {
    

    let searchController = UISearchController(searchResultsController: nil)
    let disposeBag = DisposeBag()
    
    
    var events: [Event] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        
        
        // self.tableView.tableHeaderView = self.searchController.searchBar
        // self.searchController.searchResultsUpdater = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.showsCancelButton = true
        self.searchController.searchBar.searchBarStyle = .default
        self.searchController.searchBar.barStyle = .default
        self.searchController.searchBar.delegate = self
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
        
        let searchResults = self.searchController.searchBar.rx.text.orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { query -> Observable<[Event]> in
                print(query)
                if query.isEmpty {
                    return .just([])
                }
                return self.updateFetch(query)
                    .catchErrorJustReturn([])
            }
            .observeOn(MainScheduler.instance)
        
        searchResults
            .bind(to: tableView.rx.items(cellIdentifier: "EventTableViewCell")) {
                (index, event: Event, cell: EventTableViewCell) in
                //let eventCell = cell as! EventTableViewCell
                cell.configureWithEvent(event)
                //                cell.textLabel?.text = repository.name
                //                cell.detailTextLabel?.text = repository.url
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // elf.navigationController?.setNavigationBarHidden(false, animated: animated)
        // self.searchController.dismiss(animated: false, completion: nil)
    }
    
    // MARK: Search
    func updateFetch(_ query: String? = nil, _ updateFromApi: Bool = true) -> Observable<[Event]> {
        
        let eventSubject = BehaviorSubject<[Event]>(value: [])
        var observable: RequestObservable<Event>!
        var fetchRequest: FetchRequest<Event>!
        
        do {
            
            guard let queryString = query else {
                self.events = []
                // self.tableView.reloadData()
                // eventSubject.on(.next([]))
                return eventSubject.asObserver()
            }
            
            // Update from API
            if (updateFromApi) {
                Event.getEvents(queryString)
            }
            
            // Update Local Fetch Request
            fetchRequest = FetchRequest<Event>().filtered(with: NSPredicate(format: "SELF.title CONTAINS[c] %@", queryString)).sorted(with: "title", ascending: true)
            eventSubject.on(.next(try AppData.shared.db.fetch(fetchRequest)))
            
            observable = AppData.shared.db.observable(request: fetchRequest)
            observable.observe { changes in
                do {
                    switch (changes) {
                    case .initial( _):
                        //self.events = try! AppData.shared.db.fetch(fetchRequest)
                        //self.tableView.reloadData()
                        eventSubject.on(.next(try AppData.shared.db.fetch(fetchRequest)))
                    case .update( _, _, _):
                        // self.events = try! AppData.shared.db.fetch(fetchRequest)
                        // self.tableView.reloadData()
                        eventSubject.on(.next(try AppData.shared.db.fetch(fetchRequest)))
                    case .error( _):
                        return
                        // eventSubject.onError("Error observing CoreData")
                    }
                } catch {
                    // eventSubject.onError("Error fetching in CoreData observer")
                }
                
            }
        } catch {
            // eventSubject.onError("Error observing CoreData")
        }
        return eventSubject.asObserver()
        
    }
    
    /*
     func updateSearchResults(for searchController: UISearchController) {
     if let searchText = searchController.searchBar.tex, !searchText.isEmpty {
     self.updateFetch(searchController.searchBar.text, true)
     } else {
     self.updateFetch()
     }
     }
     
     func searchBar(_ searchBar: UISearchBar,
     textDidChange searchText: String) {
     if let searchText = searchBar.text, !searchText.isEmpty {
     self.updateFetch(searchBar.text, true)
     } else {
     self.updateFetch()
     }
     }
     */
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    // MARK: UITableView
    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell
        
        cell.configureWithEvent(self.events[indexPath.row])
        
        return cell
    }
    */
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! EventDetailsViewController
        let cell = sender as! EventTableViewCell
        vc.event = cell.event!
    }
    
}

