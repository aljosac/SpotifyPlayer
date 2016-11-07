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
    
    var searchController: UISearchController = UISearchController(searchResultsController: ResultsTableController())
    
    var disposeBag = DisposeBag()
    
    var provider: RxMoyaProvider<Spotify>!
    
    var latestSearch: Observable<String> {
        return searchBar.rx.text.throttle(2, scheduler: MainScheduler.instance).distinctUntilChanged()
    }
    
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
        
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        
        setupRx()
        
    }
    
    func setupRx(){
        resultsTableView.dataSource = nil
        provider = RxMoyaProvider<Spotify>()
        
        let searchModel = SpotifySearchModel(provider: provider, query: latestSearch)
        
    
        
        let tracks = SpotifyProvider.request(.Track(name: "Fade")).debug().mapObject(type: Test.self)
        
        tracks.subscribe { event in
            switch event {
            case let .next(search):
                print(search.total)
                print(search.href)
            case let .error(error):
                dump(tracks)
            case .completed: break
                
            }
        }.addDisposableTo(disposeBag)
        /*
        searchModel.search().bindTo(resultsTableView.rx.items(cellIdentifier: "SearchResultCell")) { (_,track,cell) in
            cell.textLabel?.text = track.name
        }.addDisposableTo(disposeBag)
        
        
        result.drive(resultsTableView.rx.items(cellIdentifier: "SearchResultCell")) { (_, result, cell) in
            cell.textLabel?.text = result.name
            
        }.addDisposableTo(disposeBag)
        
         */
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
