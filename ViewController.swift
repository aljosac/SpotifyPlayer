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

class ViewController: UITableViewController, UISearchBarDelegate{
    
    var searchController: UISearchController = UISearchController(searchResultsController: UITableViewController())
    
    var disposeBag = DisposeBag()
    
    var provider: RxMoyaProvider<Spotify>!
    
    
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
        
        resultsTableView.dataSource = nil
        
        setupRx()
        
    }
    
    func setupRx(){
        
        provider = RxMoyaProvider<Spotify>()
        
        let searchModel = SpotifySearchModel(provider: provider)
        
        let results = searchBar.rx.text.throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { query in
                return searchModel.search(query: query)
            }
        
        
        var sortedResults:Observable<[Track]> = Observable.just([])
        
        results.subscribe { event in
            switch event {
            case let .next(list):
                sortedResults = Observable.just(list.sorted { $0.popularity > $1.popularity})
            case let .error(error):
                print(error)
            case .completed:
                break
            }
        }.addDisposableTo(disposeBag)
        sortedResults.bindTo(resultsTableView.rx.items(cellIdentifier: "searchCell", cellType: SpotifySearchCell.self)){
            (_,track,cell) in
                cell.mainLabel.text = track.name
                cell.sublabel.text = track.artists[0].name + ": " + "\(track.popularity)"
            }.addDisposableTo(disposeBag)
        
        // hides keyboard
        resultsTableView.rx.contentOffset
            .asDriver()
            .drive(onNext: { _ in
                if self.searchBar.isFirstResponder {
                    _ = self.searchBar.resignFirstResponder()
                }
            })
            .addDisposableTo(disposeBag)
        
        resultsTableView.rx.itemSelected.subscribe{ index in
            print(index.debugDescription)
            
            self.searchBar.resignFirstResponder()
            }.addDisposableTo(disposeBag)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "HISTORY"
        case 1:
            return "TRENDING"
        default:
            return "wat"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "text") {
            print("1111")
            return cell
        }
        let cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = "ONE"
        return cell
    }
    
}

extension ViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("abcd")
    }
}
