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
import RxDataSources

class SearchViewController: UITableViewController, UISearchBarDelegate{
    
    var searchController: UISearchController = UISearchController(searchResultsController: ResultsTableViewController())
    
    var mainTabBarController:MainTabBarController {
        return (self.navigationController!.tabBarController as! MainTabBarController)
    }
    
    var disposeBag = DisposeBag()
    let provider = RxMoyaProvider<Spotify>(endpointClosure: requestClosure)
    var queueAdded:Variable<[Track]> = Variable.init([])
    var results:Observable<[SearchResultSectionModel]>? = nil
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

        // Set up view
        searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        // load result cell layout
        resultsTableView.register(UINib(nibName: "TrackTableViewCell", bundle:nil), forCellReuseIdentifier: "trackCell")
        resultsTableView.register(UINib(nibName: "ArtistTableViewCell", bundle:nil), forCellReuseIdentifier: "artistCell")
        
        tableView.register(UINib(nibName: "ResultTableViewCell", bundle:nil), forCellReuseIdentifier: "resultCell")
        tableView.register(UINib(nibName: "ArtistTableViewCell", bundle:nil), forCellReuseIdentifier: "artistCell")
        
        setupHome()
        setupSearch()
        setupSearchBindings()
    }
    
    
    
    
    func setupHome(){
        // get search model and top artists
        let spotifyModel = SpotifyModel(provider: provider)
        
        // Get any existing history values
        history = Set(UserDefaults.standard.array(forKey: "History") as? [String] ?? [])
        let historyItems = Array(history).map {SectionItem.HistorySectionItem(title: $0)}
        
        // Create the datadatasource for the home search screen
        let datasource = RxTableViewSectionedReloadDataSource<SearchHomeSectionModel>()
        searchHomeDataSource(datasource: datasource)
        
        // Inital section
        let sections = Variable([SearchHomeSectionModel.HistorySection(items: historyItems)])
        
        spotifyModel.topArtists().subscribe { event in
            switch event {
            case let .next(list):
                let newls = list.map {SectionItem.TopArtistSectionItem(artist: $0)}
                if newls.count != 0 {
                    sections.value = [SearchHomeSectionModel.HistorySection(items: historyItems),SearchHomeSectionModel.TopArtistsSection(items: newls)]
                }
            case .error(_):
                print("error top Artist")
            case .completed:
                break
            }
            }.addDisposableTo(disposeBag)
        
        tableView.dataSource = nil
        sections.asObservable()
            .bindTo(self.tableView.rx.items(dataSource: datasource))
            .addDisposableTo(disposeBag)
    }
    
    func setupSearch(){
        
        
        resultsTableView.dataSource = nil
        let spotifyModel = SpotifyModel(provider: provider)
                // Throttle typing and send http search request
        results = searchBar.rx.text.orEmpty.throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { query in
                return spotifyModel.search(query: query)
            }.map { result in
                // setup section array
                var sections:[SearchResultSectionModel] = []
                
                // sorts and adds Tracks to search results if any exist
                let sortedTracks = result.tracks.sorted(by: {$0.popularity > $1.popularity})
                    .map {SearchItem.TrackItem(track: $0)}
                if sortedTracks.count > 0 {
                    let count = min(sortedTracks.count,10)
                    let section = Array(sortedTracks.prefix(through: count-1))
                    sections.append(.TrackSection(items: section))
                }
                
                // sorts and adds Artists to search results if any exist
                let sortedArtists = result.artists.sorted(by: {$0.popularity > $1.popularity})
                    .map {SearchItem.ArtistItem(artist: $0)}
                if sortedArtists.count > 0 {
                    let count = min(sortedArtists.count,3)
                    let section = Array(sortedArtists.prefix(through: count-1))
                    sections.append(.ArtistSection(items: section))
                }
                return sections
            }
        
        // datasource setup
        let dataSource = RxTableViewSectionedReloadDataSource<SearchResultSectionModel>()
        searchResultDataSource(datasource: dataSource)
        
        
        // populate table view with items from sorted results
        results!.bindTo(resultsTableView.rx.items(dataSource: dataSource))
                .addDisposableTo(disposeBag)
        print(resultsTableView.delegate.debugDescription)
        print(tableView.delegate.debugDescription)
    }
    
    func setupSearchBindings(){
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
                
                let cell = self.resultsTableView.cellForRow(at: index) as! ResultTableViewCell
                switch cell.cellType! {
                case .TrackCell:
                    let trackCell = cell as! TrackTableViewCell
                    self.mainTabBarController.presentPlayer()
                    self.mainTabBarController.queueViewController.queue.value.append(trackCell.track!)
                    self.searchBar.resignFirstResponder()
                    self.addAndSaveHistory()
                case .ArtistCell:
                    let artistCell = cell as! ArtistTableViewCell
                    let artistPage = ArtistPageViewController(artist: artistCell.artist!)
                    self.present(artistPage, animated: true, completion: nil)
                default:
                    break
                }
                
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
       //resultsTableView.sectionHeaderHeight = 80
    }
    
    
    // searchHomeDataSource
    func searchHomeDataSource(datasource:RxTableViewSectionedReloadDataSource<SearchHomeSectionModel>){
        
        datasource.configureCell = { (dataSource, table, idxPath, _) in
            switch datasource[idxPath] {
            case let .HistorySectionItem(title):
                let cell = table.dequeueReusableCell(withIdentifier: "resultCell", for: idxPath)
                cell.textLabel?.text = title
                return cell
            case let .TopArtistSectionItem(artist):
                let cell = table.dequeueReusableCell(withIdentifier: "artistCell", for: idxPath) as! ArtistTableViewCell
                
                cell.artist = artist
                cell.name.text = artist.name
                return cell
            }
        }
        
        datasource.titleForHeaderInSection = { datasource, idx in
            let section = datasource[idx]
            return section.title
        }
        
        
    }
    
    func searchResultDataSource(datasource:RxTableViewSectionedReloadDataSource<SearchResultSectionModel>){
        datasource.configureCell = { (dataSource, table, idxPath, _) in
            switch dataSource[idxPath] {
            case let .ArtistItem(artist):
                let cell = table.dequeueReusableCell(withIdentifier: "artistCell", for: idxPath) as!
                    ArtistTableViewCell
                cell.name.text = artist.name
                cell.artist = artist
                
                if artist.images.count > 0 {
                    Alamofire.request(artist.images[0].url).responseData { response in
                        if let data = response.data {
                            let image:UIImage = UIImage(data: data)!
                            cell.artistImage.image = image
                        }
                    }
                }
                return cell
            case let .TrackItem(track):
                let cell = table.dequeueReusableCell(withIdentifier: "trackCell", for: idxPath) as! TrackTableViewCell
                cell.mainLabel.text = track.name
                cell.sublabel.text = track.artists[0].name
                cell.track = track
                return cell
            case let .AlbumItem(album):
                let cell = table.dequeueReusableCell(withIdentifier: "albumCell", for: idxPath) as! AlbumTableViewCell
                cell.albumName.text = album.name
                return cell
            }
            
        }
        
        datasource.titleForHeaderInSection = { datasource, idx in
            return datasource[idx].title
        }
        
    }
    
    //MARK: - Delegate Methods
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textAlignment = .center
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ResultTableViewCell
        switch cell.cellType! {
        case .ArtistCell:
            let artistCell = cell as! ArtistTableViewCell
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let artistPage = storyboard.instantiateViewController(withIdentifier: "artistPage") as! ArtistPageViewController
        
            artistPage.artist = artistCell.artist!
            self.navigationController?.pushViewController(artistPage, animated: true)
        default:
            let txt = cell.textLabel?.text
            self.searchController.isActive = true
            self.searchController.searchBar.text = txt!
            self.setupSearch()
        }
        
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
