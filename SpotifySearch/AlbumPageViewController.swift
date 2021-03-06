//
//  AlbumPageViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/20/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxDataSources

class AlbumPageViewController: UIViewController,UITableViewDelegate {

    override var preferredStatusBarStyle:UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var albumBar:AlbumStyleBar? = nil
    var disposeBag = DisposeBag()
    var album:SimpleAlbum? = nil
    var albumImage:UIImage? = nil
    var trackList:Variable<[AlbumPageSectionModel]> = Variable([])
    var delegateSplitter:BLKDelegateSplitter? = nil
    
    let provider = RxMoyaProvider<Spotify>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "TrackTableViewCell", bundle:nil),forCellReuseIdentifier: "trackCell")
        let albumRect:CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 300)
        let spotifyModel = SpotifyModel(provider: provider)
        self.tableView.indicatorStyle = .white
        self.tableView.separatorColor = tableGray
        self.tableView.backgroundColor = tableGray
        
        let activityView = UIActivityIndicatorView(frame: self.view.frame)
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        spotifyModel.getAlbum(id: self.album!.id).subscribe{ event in
            switch event {
            case let .next(album):
                print("receaved request")
                self.album = album
                
                self.albumBar = AlbumStyleBar(frame: albumRect, name: album.name,image: self.albumImage)
                let behavior:BarBehavior = BarBehavior()
                behavior.addSnappingPositionProgress(0.0, forProgressRangeStart: 0.0, end: 0.5)
                behavior.addSnappingPositionProgress(1.0, forProgressRangeStart: 0.5, end: 1.0)
                behavior.isSnappingEnabled = true
                behavior.isElasticMaximumHeightAtTop = true
                
                self.albumBar?.behaviorDefiner = behavior
                self.delegateSplitter = BLKDelegateSplitter(firstDelegate: behavior, secondDelegate: self)
                self.tableView.delegate = self.delegateSplitter
                self.view.addSubview(self.albumBar!)
                
                let playerHeight:CGFloat = AppState.shared.playerShowing ? 64.0 : 0.0
                let insets = UIEdgeInsetsMake(self.albumBar!.maximumBarHeight, 0.0, 50+playerHeight, 0.0)
                
                self.tableView.contentInset = insets
                self.tableView.scrollIndicatorInsets = insets
                
                let backButton = UIButton(type: .custom)
                backButton.frame = CGRect(x: 10, y: 25, width: 30, height: 30)
                backButton.tintColor = .white
                backButton.setImage(#imageLiteral(resourceName: "BackArrow"), for: .normal)
                backButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
                self.albumBar?.addSubview(backButton)
                
                let trackIds = album.tracks.items.map {$0.id}.joined(separator: ",")
                spotifyModel.getTracks(id:trackIds).subscribe { event in
                    switch event {
                    case let .next(response):
                        let tracks = response.map{AlbumItem.AlbumTrack(track: $0)}
                        let trackSection = AlbumPageSectionModel.TrackSection(items: tracks)
                        self.trackList.value = [trackSection]
                    case .error,.completed:
                        break
                    }
                }.addDisposableTo(self.disposeBag)
                
                let datasource = RxTableViewSectionedReloadDataSource<AlbumPageSectionModel>()
                self.albumPageDataSource(datasource: datasource)
                activityView.stopAnimating()
                self.trackList.asObservable().bindTo(self.tableView.rx.items(dataSource: datasource)).addDisposableTo(self.disposeBag)
            case let .error(error):
                print(error.localizedDescription)
            case .completed:
                break
            }
        }.addDisposableTo(disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        super.viewWillAppear(animated)
    }
    func albumPageDataSource(datasource:RxTableViewSectionedReloadDataSource<AlbumPageSectionModel>) {
        
        datasource.configureCell = { (dataSource, table, idxPath, _) in
            switch datasource[idxPath] {
            case let .AlbumTrack(track):
                let cell = table.dequeueReusableCell(withIdentifier: "trackCell", for: idxPath) as! TrackTableViewCell
                // Configure Cell
                cell.mainLabel.text = track.name
                let artists = track.artists.map{ $0.name }
                cell.sublabel.text = artists.joined(separator: ", ")
                cell.track = track
                cell.backgroundColor = tableGray
                cell.mainLabel.textColor = .white
                cell.sublabel.textColor = .white
                cell.tintColor = appGreen
                
                // Using resuable cell must reset accessory type
                cell.accessoryType = .none
                if AppState.shared.queueIds.contains(track.id) {
                    cell.accessoryType = .checkmark
                }
                return cell
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ResultTableViewCell
        switch cell.cellType! {
        case .TrackCell:
            let trackCell = cell as! TrackTableViewCell
            print("posting")
            NotificationCenter.default.post(name: Notification.Name("addTrack"), object: nil, userInfo: ["track":trackCell.track!])
            let insets = UIEdgeInsetsMake(self.albumBar!.maximumBarHeight, 0.0, 50+64, 0.0)
            
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
            trackCell.accessoryType = .checkmark
           
        default:
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath) as? ResultTableViewCell {
            switch cell.cellType! {
            case .TrackCell:
                if cell.accessoryType == .checkmark {
                    return nil
                }
                fallthrough
            default:
                return indexPath
            }
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let cell = tableView.cellForRow(at: indexPath) as? ResultTableViewCell {
            switch cell.cellType! {
            case .TrackCell:
                if cell.accessoryType == .checkmark {
                    return false
                }
                fallthrough
            default:
                return true
            }
        }
        return true
    }
    
}


extension AlbumPageViewController: UIGestureRecognizerDelegate {}
