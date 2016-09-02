//
//  ViewController.swift
//  SpotifySearch
//
//  Created by cse-cucak003 on 8/26/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UITableViewController, UISearchBarDelegate{

    var searchController: UISearchController = UISearchController(searchResultsController: ResultsTableController())
    var disposeBag = DisposeBag()
    
    private var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    private var resultsViewController: UITableViewController {
        return (self.searchController.searchResultsController as? UITableViewController)!
    }
    
    private var resultsTableView: UITableView {
        return self.resultsViewController.tableView!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        
        setupRx()
        
    }
    
    func setupRx(){
        searchBar.rx_text
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribeNext { query in
                print("sent")
            }.addDisposableTo(disposeBag)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "HISTORY"
        case 1:
            return "TRENDING"
        default:
            return "wat"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("text") {
            print("1111")
            return cell
        }
        let cell = UITableViewCell.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = "ONE"
        return cell
    }
    
}

extension ViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print("abcd")
    }
}
