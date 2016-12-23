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

    @IBOutlet weak var tableView: UITableView!
    
    var albumBar:AlbumStyleBar? = nil
    var disposeBag = DisposeBag()
    var album:FullAlbum? = nil
    var albumImage:UIImage? = nil
    var trackList:Variable<[AlbumPageSectionModel]> = Variable([])
    var delegateSplitter:BLKDelegateSplitter? = nil
    var id:String? = nil
    
    let provider = RxMoyaProvider<Spotify>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "TrackTableViewCell", bundle:nil),forCellReuseIdentifier: "trackCell")
        let albumRect:CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 300)
        let spotifyModel = SpotifyModel(provider: provider)
        spotifyModel.getAlbum(id: self.id!).subscribe{ event in
            switch event {
            case let .next(album):
                print("receaved request")
                self.album = album
                
                self.albumBar = AlbumStyleBar(frame: albumRect, album: album,image: self.albumImage)
                let behavior:BarBehavior = BarBehavior()
                behavior.addSnappingPositionProgress(0.0, forProgressRangeStart: 0.0, end: 0.5)
                behavior.addSnappingPositionProgress(1.0, forProgressRangeStart: 0.5, end: 1.0)
                behavior.isSnappingEnabled = true
                behavior.isElasticMaximumHeightAtTop = true
                
                self.albumBar?.behaviorDefiner = behavior
                self.delegateSplitter = BLKDelegateSplitter(firstDelegate: behavior, secondDelegate: self)
                self.tableView.delegate = self.delegateSplitter
                self.view.addSubview(self.albumBar!)
                
                self.tableView.contentInset = UIEdgeInsetsMake(self.albumBar!.maximumBarHeight, 0.0, 0.0, 0.0)
                
                let trackIds = album.tracks.map {$0.id}.joined(separator: ",")
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
                self.trackList.asObservable().bindTo(self.tableView.rx.items(dataSource: datasource)).addDisposableTo(self.disposeBag)
            case let .error(error):
                print(error.localizedDescription)
            case .completed:
                break
            }
        }.addDisposableTo(disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        super.viewWillAppear(animated)
    }
    func albumPageDataSource(datasource:RxTableViewSectionedReloadDataSource<AlbumPageSectionModel>) {
        
        datasource.configureCell = { (dataSource, table, idxPath, _) in
            switch datasource[idxPath] {
            case let .AlbumTrack(track):
                let cell = table.dequeueReusableCell(withIdentifier: "trackCell", for: idxPath) as! TrackTableViewCell
            
                cell.mainLabel.text = track.name
                let artists = track.artists.map{ $0.name }
                cell.sublabel.text = artists.joined(separator: ", ")
                cell.track = track
                return cell
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ResultTableViewCell
        switch cell.cellType! {
        case .TrackCell:
            let trackCell = cell as! TrackTableViewCell
            print("posting")
            NotificationCenter.default.post(name: Notification.Name("addTrack"), object: nil, userInfo: ["track":trackCell.track!])
        default:
            return
        }
    }
    
    
    
}


extension AlbumPageViewController: UIGestureRecognizerDelegate {}
