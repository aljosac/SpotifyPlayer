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
    
    override var preferredStatusBarStyle:UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    var disposeBag = DisposeBag()
    let provider = RxMoyaProvider<Spotify>(endpointClosure: requestClosure)
    var queueAdded:Variable<[FullTrack]> = Variable.init([])
    var results:Observable<[SearchResultSectionModel]>? = nil
    var history:Set<String> = []
    
    fileprivate var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    fileprivate var resultsViewController: ResultsTableViewController {
        return (self.searchController.searchResultsController as? ResultsTableViewController)!
    }
    
    fileprivate var resultsTableView: UITableView {
        return self.resultsViewController.tableView!
    }
    
    
    // MARK: - View Controller Setup Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Set up view
        searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.titleView = searchController.searchBar
        
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = dark
        self.navigationController?.navigationBar.isTranslucent = false
        self.definesPresentationContext = true
        // load result cell layout
        resultsTableView.register(UINib(nibName: "TrackTableViewCell", bundle:nil), forCellReuseIdentifier: "trackCell")
        resultsTableView.register(UINib(nibName: "ArtistTableViewCell", bundle:nil), forCellReuseIdentifier: "artistCell")
        resultsTableView.register(UINib(nibName: "AlbumTableViewCell", bundle:nil), forCellReuseIdentifier: "albumCell")
        resultsTableView.register(ExpandTableViewCell.self, forCellReuseIdentifier: "expandCell")
        
        tableView.register(UINib(nibName: "ResultTableViewCell", bundle:nil), forCellReuseIdentifier: "resultCell")
        tableView.register(UINib(nibName: "ArtistTableViewCell", bundle:nil), forCellReuseIdentifier: "artistCell")
        tableView.backgroundColor = tableGray
        tableView.separatorColor = tableGray
        
        resultsTableView.backgroundColor = tableGray
        
        setupHome()
        setupSearch()
        setupBindings()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if AppState.shared.playerShowing {
            let insets = UIEdgeInsetsMake(0, 0, 50+64, 0)
            
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
        }
        super.viewWillAppear(animated)
    }
    
    func setupHome(){
        // get search model and top artists
        let spotifyModel = SpotifyModel(provider: provider)
        
        // Get any existing history values
        history = Set(UserDefaults.standard.array(forKey: "History") as? [String] ?? [])
        var historyItems:[SectionItem] = Array(history).map {SectionItem.HistorySectionItem(title: $0)}
        historyItems = Array(historyItems.prefix(10))
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
                print("error Top Artist")
            case .completed:
                break
            }
            }.addDisposableTo(disposeBag)
        
        tableView.dataSource = nil
        tableView.delegate = self
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
                
                // Adds Tracks
                let sortedTracks = result.tracks.items.sorted(by: {$0.popularity > $1.popularity})
                    .map {SearchItem.TrackItem(track: $0)}
                
                    var count = min(sortedTracks.count,10)
                    var tracks:[SearchItem] = Array(sortedTracks.prefix(through: count-1))
                    tracks.append(SearchItem.ExpandItem(type: EndCell.Track(text: trackText, page: result.tracks)))
                    sections.append(.TrackSection(items: tracks))
                
                
                // Adds Artists
                let sortedArtists = result.artists.items.sorted(by: {$0.popularity > $1.popularity})
                    .map {SearchItem.ArtistItem(artist: $0)}
                
                     count = min(sortedArtists.count,3)
                    var artists:[SearchItem] = Array(sortedArtists.prefix(through: count-1))
                    artists.append(SearchItem.ExpandItem(type: EndCell.Artist(text: artistText, page: result.artists)))
                    sections.append(.ArtistSection(items: artists))
                
                // Adds Albums
                let sortedAlbums = result.albums.items.map{SearchItem.SearchAlbumItem(album: $0)}
                
                     count = min(sortedAlbums.count,3)
                    var albums = Array(sortedAlbums.prefix(through: count-1))
                    albums.append(SearchItem.ExpandItem(type: EndCell.Album(text: albumText,type:"album", page: result.albums)))
                    sections.append(.AlbumSection(items: albums))
                
                // Adds Playlists
                let sortedPlaylists = result.playlist.items.map{SearchItem.PlaylistItem(playlist: $0)}
                
                    count = min(sortedAlbums.count,3)
                    var playlists = Array(sortedPlaylists.prefix(through: count-1))
                    playlists.append(SearchItem.ExpandItem(type: EndCell.Playlist(text: playlistText, page: result.playlist)))
                    sections.append(.PlaylistSection(items: playlists))
                // Gets top section
                var findTop = Array.init(sortedTracks)
                findTop.append(contentsOf: Array.init(sortedArtists))
                findTop.append(contentsOf: Array.init(sortedAlbums))
                findTop.append(contentsOf: Array.init(sortedPlaylists))
                let topItem = calcTop(query: self.searchBar.text!, items: findTop)
                
                if let t = topItem {
                    let temp:[SearchResultSectionModel] = [.TopResultSection(items:[t])]
                    sections = temp + sections
                }
                
                
                return sections
            }
        
        // datasource setup
        let dataSource = RxTableViewSectionedReloadDataSource<SearchResultSectionModel>()
        searchResultDataSource(datasource: dataSource)
        
        
        // populate table view with items from sorted results
        results!.bindTo(resultsTableView.rx.items(dataSource: dataSource))
                .addDisposableTo(disposeBag)
    }
    
    func setupBindings(){
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
                    trackCell.accessoryType = .checkmark
                    NotificationCenter.default.post(name: Notification.Name("addTrack"), object: nil, userInfo: ["track":trackCell.track!])
                    self.resultsViewController.resize()
                    self.searchBar.resignFirstResponder()
                case .ArtistCell:
                    let artistCell = cell as! ArtistTableViewCell
        
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let artistPage = storyboard.instantiateViewController(withIdentifier: "artistPage") as! ArtistPageViewController
                    artistPage.artist = artistCell.artist!
                    self.navigationController?.pushViewController(artistPage, animated: true)
                case .AlbumCell:
                    let albumCell = cell as! AlbumTableViewCell
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let albumPage = storyboard.instantiateViewController(withIdentifier:"albumPage") as! AlbumPageViewController
                    
                    albumPage.album = albumCell.album
                    albumPage.albumImage = albumCell.albumCover.image
                    self.navigationController?.pushViewController(albumPage, animated: true)
                case .PlaylistCell:
                    let playlistCell = cell as! AlbumTableViewCell
                    
                    let playlistController = PlaylistPageViewController(loader: playlistCell.playlist!)
                    self.navigationController?.pushViewController(playlistController, animated: true)
                case .ExpandCell:
                    let expandCell = cell as! ExpandTableViewCell
                    let expandController = ExpandTableViewController(info: expandCell.info!, style: .plain)
                    self.navigationController?.pushViewController(expandController, animated: true)
                default:
                    break
                }
                self.addAndSaveHistory()
                self.resultsTableView.deselectRow(at: index, animated: true)
                self.resultsTableView.reloadData()
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
    
    
    // MARK: - Home Data Source
    func searchHomeDataSource(datasource:RxTableViewSectionedReloadDataSource<SearchHomeSectionModel>){
        
        datasource.configureCell = { (dataSource, table, idxPath, _) in
            switch datasource[idxPath] {
            case let .HistorySectionItem(title):
                let cell = table.dequeueReusableCell(withIdentifier: "resultCell", for: idxPath) as! ResultTableViewCell
                cell.backgroundColor = tableGray
                cell.textLabel?.text = title
                cell.textLabel?.textColor = .white
                cell.cellType = .HistoryCell
                return cell
            case let .TopArtistSectionItem(artist):
                let cell = table.dequeueReusableCell(withIdentifier: "artistCell", for: idxPath) as! ArtistTableViewCell
                cell.backgroundColor = tableGray
                cell.name.textColor = .white
                if artist.images.count > 0 {
                    Alamofire.request(artist.images[0].url).responseData { response in
                        if let data = response.data {
                            let image:UIImage = UIImage(data: data)!
                            cell.artistImage.image = image
                            cell.artist?.images[0].image = image
                        }
                    }
                }
                
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
    
    // MARK: - Result Data Source
    func searchResultDataSource(datasource:RxTableViewSectionedReloadDataSource<SearchResultSectionModel>){
        datasource.configureCell = { (dataSource, table, idxPath, _) in
            switch dataSource[idxPath] {
            case let .ArtistItem(artist):
                let cell = table.dequeueReusableCell(withIdentifier: "artistCell", for: idxPath) as!
                    ArtistTableViewCell
                cell.artist = artist
                cell.configureCell()
                if idxPath.section == 0 {
                    self.resultsViewController.topType = .ArtistCell
                    self.tableView.reloadRows(at: [idxPath], with: .automatic)
                }
                return cell
            case let .TrackItem(track):
                let cell = table.dequeueReusableCell(withIdentifier: "trackCell", for: idxPath) as! TrackTableViewCell
                cell.track = track
                if idxPath.section == 0 {
                    self.resultsViewController.topType = .TrackCell
                    self.tableView.reloadRows(at: [idxPath], with: .automatic)
                }
                cell.configureCell()
                
                return cell
            case let .SearchAlbumItem(album):
                let cell = table.dequeueReusableCell(withIdentifier: "albumCell", for: idxPath) as! AlbumTableViewCell
                cell.album = album
                cell.configureCell()
                if idxPath.section == 0 {
                    self.resultsViewController.topType = .AlbumCell
                    self.tableView.reloadRows(at: [idxPath], with: .automatic)
                }
                return cell
            case let .PlaylistItem(playlist):
                let cell = table.dequeueReusableCell(withIdentifier: "albumCell", for: idxPath) as! AlbumTableViewCell
                cell.playlist = playlist
                cell.configureCell()
                cell.cellType = .PlaylistCell
                if idxPath.section == 0 {
                    self.resultsViewController.topType = .AlbumCell
                    self.tableView.reloadRows(at: [idxPath], with: .automatic)
                }
                return cell
            case let .ExpandItem(endCell):
                let cell = table.dequeueReusableCell(withIdentifier: "expandCell", for: idxPath) as! ExpandTableViewCell
                
                switch endCell {
                case let .Track(text, _):
                    cell.textLabel?.text = text
                case let .Artist(text,_):
                    cell.textLabel?.text = text
                case let .Album(text,_,_):
                    cell.textLabel?.text = text
                case let .Playlist(text,_):
                    cell.textLabel?.text = text
                }
                cell.textLabel?.textColor = .white
                cell.cellType = .ExpandCell
                cell.info = endCell
                cell.accessoryType = .disclosureIndicator
                cell.backgroundColor = tableGray
                return cell
            default:
                return UITableViewCell()
            }
            
        }
        
        datasource.titleForHeaderInSection = { datasource, idx in
            return datasource[idx].title
        }
        
    }
    
    //MARK: - Home Delegate Methods
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textAlignment = .center
            header.textLabel?.textColor = .white
            header.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
            header.contentView.backgroundColor = tableGray
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return min(5,self.history.count)
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
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1 :
            return 60
        default:
            return 44
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

extension SearchViewController: UIGestureRecognizerDelegate {}
