//
//  ViewController.swift
//  SpotifySearch
//
//  Created by cse-cucak003 on 8/26/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
import Moya
import Alamofire


class SearchViewController: UITableViewController, UISearchBarDelegate{
    
    var searchController: UISearchController = UISearchController(searchResultsController: UITableViewController())
    
    var mainTabBarController:MainTabBarController {
        return (self.navigationController!.tabBarController as! MainTabBarController)
    }
    
    var disposeBag = DisposeBag()
    
    var provider: RxMoyaProvider<Spotify>!
    
    var queueAdded:Variable<[Track]> = Variable.init([])
    
    var results:Observable<[Track]>? = nil
    
    var history:Set<String> = []
    
    
    fileprivate var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    fileprivate var resultsViewController: UITableViewController {
        return (self.searchController.searchResultsController as? UITableViewController)!
    }
    
    fileprivate var resultsTableView: UITableView {
        return self.resultsViewController.tableView!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.titleView = searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        
        resultsTableView.register(UINib(nibName: "SpotifySearchCell", bundle:nil), forCellReuseIdentifier: "searchCell")
        
        history = Set(UserDefaults.standard.array(forKey: "History") as? [String] ?? [])
        
        
        setupRx()
    }
    
    func setupRx(){
        resultsTableView.dataSource = nil

        provider = RxMoyaProvider<Spotify>()
        let searchModel = SpotifySearchModel(provider: provider)
        
        // Throttle typing and send http search request
         results = searchBar.rx.text.orEmpty.throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { query in
                return searchModel.search(query: query)
            }
        
        // sorts results of search request by most popular
        let sortedResults = results!.map { list in
            return list.sorted(by: { $0.popularity > $1.popularity })
        }
        
        // populate table view with items from sorted results
        sortedResults.bindTo(resultsTableView.rx.items(cellIdentifier: "searchCell", cellType: SpotifySearchCell.self)){
            (_,track,cell) in
                cell.mainLabel.text = track.name
                cell.sublabel.text = track.artists[0].name + " - " + "\(track.album.name)"
                cell.track = track
            }.addDisposableTo(disposeBag)
        
        // hides keyboard
        resultsTableView.rx.contentOffset
            .asDriver()
            .drive(onNext: { _ in
                if self.searchBar.isFirstResponder {
                    _ = self.searchBar.resignFirstResponder()
                }
                self.addAndSaveHistory()
            })
            .addDisposableTo(disposeBag)
        
        resultsTableView.rx.itemSelected.subscribe{ event in
            switch event {
            case let .next(index):
                // Get Cell information
                //self.view.window?.rootViewController?.view.viewWithTag(1337)?.isHidden = true
                let cell = self.resultsTableView.cellForRow(at: index) as! SpotifySearchCell
                self.mainTabBarController.queueViewController!.queue.value.append(cell.track!)
                self.searchBar.resignFirstResponder()
                self.addAndSaveHistory()
            case let .error(error):
                print(error.localizedDescription)
            case .completed:
                break
            }
            }.addDisposableTo(disposeBag)
        
        self.searchBar.rx.searchButtonClicked.subscribe { event in
            switch event {
            case .next(_):
                self.searchBar.resignFirstResponder()
                self.addAndSaveHistory()
            case let .error(error):
                print(error.localizedDescription)
            case .completed:
                break
                
            }
        }.addDisposableTo(disposeBag)
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textAlignment = .center
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "HISTORY"
        case 1:
            return "YOUR TOP ARTISTS"
        default:
            return "wat"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return min(10,self.history.count)
        case 1:
            return 5
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: nil)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = Array(history)[indexPath.item]
        case 1:
            cell.textLabel?.text = "Spotify Artist"
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let txt = cell?.textLabel?.text
        self.searchController.isActive = true
        self.searchController.searchBar.text = txt!
        self.setupRx()
    }
    
    func addAndSaveHistory(){
        if (self.searchBar.text != nil) && self.searchBar.text != "" {
            let text = self.searchBar.text!
            self.history.insert(text)
            let array = Array(self.history)
            UserDefaults.standard.setValue(array, forKey: "History")
        }
        self.tableView.reloadData()
    }
}


extension SearchViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("abcd")
    }
}
