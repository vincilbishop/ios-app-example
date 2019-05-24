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

class EventsTableViewController: UITableViewController, UISearchBarDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    let disposeBag = DisposeBag()
    var observable: RequestObservable<Event>!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
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
                cell.configureWithEvent(event)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: Search
    func updateFetch(_ query: String? = nil, _ updateFromApi: Bool = true) -> Observable<[Event]> {
        
        let eventSubject = BehaviorSubject<[Event]>(value: [])
        
        guard let queryString = query else {
            eventSubject.on(.next([]))
            return eventSubject.asObserver()
        }
        
        // Update from API
        if (updateFromApi) {
            Event.getEvents(queryString) { (response) in
                
                guard let events = response else {
                    eventSubject.on(.next([]))
                    return
                }
                
                let fetchRequest: FetchRequest<Event>! = FetchRequest<Event>().filtered(with: NSPredicate(format: "SELF in %@", events.array)).sorted(with: "title", ascending: true)
                do {
                    eventSubject.on(.next(try AppData.shared.db.fetch(fetchRequest)))
                } catch {
                    eventSubject.onError("Error after Event API call")
                }
            }
        }
        
        return eventSubject.asObserver()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! EventDetailsViewController
        let cell = sender as! EventTableViewCell
        vc.event = cell.event!
    }
}
