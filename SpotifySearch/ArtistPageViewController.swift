//
//  ArtistViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/9/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxDataSources
import Alamofire

class ArtistPageViewController: UITableViewController {

    var artistBar:ArtistStyleBar? = nil
    var artist:FullArtist
    var delegateSplitter:BLKDelegateSplitter? = nil
    let provider = RxMoyaProvider<Spotify>(endpointClosure: requestClosure)
    var disposeBag = DisposeBag()
    let sections:Variable<[ArtistPageSectionModel]> = Variable([.TopTracksSection(items: []),.AlbumsSection(items: []),
                                                                .SinglesSection(items: []),.RelatedSection(items:[])])
    
    init(artist:FullArtist) {
        self.artist = artist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let artistRect:CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 200)
        self.artistBar = ArtistStyleBar(frame: artistRect, artist: artist)
        
        let behavior:ArtistBarBehavior = ArtistBarBehavior()
        behavior.addSnappingPositionProgress(0.0, forProgressRangeStart: 0.0, end: 0.5)
        behavior.addSnappingPositionProgress(1.0, forProgressRangeStart: 0.5, end: 1.0)
        behavior.isElasticMaximumHeightAtTop = true
        self.artistBar?.behaviorDefiner = behavior
        
        self.view.addSubview(self.artistBar!)
        
        self.tableView.register(UINib(nibName: "TrackTableViewCell", bundle:nil),
                                forCellReuseIdentifier: "trackCell")
        self.tableView.contentInset = UIEdgeInsetsMake(self.artistBar!.maximumBarHeight, 0.0, 0.0, 0.0)
        
        // Request info for UITableView
        getSections()
        self.tableView.dataSource = nil
        let datasource = RxTableViewSectionedReloadDataSource<ArtistPageSectionModel>()
        artistPageDataSource(datasource:datasource)
        self.sections.asObservable().bindTo(self.tableView.rx.items(dataSource: datasource)).addDisposableTo(disposeBag)
    }

    func getSections() {
        let spotifyModel = SpotifyModel(provider: provider)
        
        spotifyModel.getTopArtistTracks(id: artist.id).subscribe { event in
            switch event {
            case let .next(trackList):
                let topArtists = trackList.map{SearchItem.TrackItem(track: $0)}
                self.sections.value[0] = ArtistPageSectionModel.TopTracksSection(items: topArtists)
            case .error,.completed:
                break
            }
        }.addDisposableTo(disposeBag)
        
    }
    
    func artistPageDataSource(datasource:RxTableViewSectionedReloadDataSource<ArtistPageSectionModel>){
        
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
            let section = datasource[idx]
            return section.title
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - ArtistTableViewSectionModel

enum ArtistSectionModel {
    case TopTrackSection(items:[SearchItem])
    case Albums(items:[SearchItem])
}




