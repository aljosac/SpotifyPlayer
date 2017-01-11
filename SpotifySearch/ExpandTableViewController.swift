//
//  ExpandTableViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/30/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import Alamofire
import Moya
import RxSwift
import Mapper
import RxCocoa

class ExpandTableViewController: UITableViewController {

    let info:EndCell
    
    init(info:EndCell, style: UITableViewStyle) {
        self.info = info
        switch info {
        case let .Album(_, _, page):
            page.items = page.items.removeDuplicates()
        default:
            break
        }
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib.init(nibName: "AlbumTableViewCell", bundle: nil), forCellReuseIdentifier: "albumCell")
        self.tableView.register(UINib.init(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        self.tableView.register(UINib.init(nibName: "ArtistTableViewCell", bundle: nil), forCellReuseIdentifier: "artistCell")

        self.tableView.backgroundColor = tableGray
        self.tableView.separatorColor = tableGray
        
        switch info {
        case let .Album(_, type,_):
            self.title = type.uppercased()
        case .Track:
            self.title = "Tracks"
        case .Artist:
            self.title = "Artists"
        }
        self.tableView.estimatedRowHeight = 60
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resize()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch info {
        case .Album(_,_,let page):
            return page.items.count
        case .Track(text: _, let page):
            return page.items.count
        case .Artist(text: _, page: let page):
            return page.items.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch info {
        case .Artist(text: _, page: _),.Album(text: _, type: _, page: _):
            return 60
        case .Track(text: _, page: _):
            return 44
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch info {
        case let .Album(_,_, page):
            return makeAlbumCell(page: page, indexPath: indexPath)
        case let .Track(_,page):
            return makeTrackCell(page: page, indexPath: indexPath)
        case let .Artist(_,page):
            return makeArtistCell(page: page, indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch info {
        case .Track(text: _, _):
            let trackCell = tableView.cellForRow(at: indexPath) as! TrackTableViewCell
            trackCell.accessoryType = .checkmark
            NotificationCenter.default.post(name: Notification.Name("addTrack"), object: nil, userInfo: ["track":trackCell.track!])
        case .Artist(text: _, _):
            let artistCell = tableView.cellForRow(at: indexPath) as! ArtistTableViewCell
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let artistPage = storyboard.instantiateViewController(withIdentifier: "artistPage") as! ArtistPageViewController
            artistPage.artist = artistCell.artist!
            self.navigationController?.pushViewController(artistPage, animated: true)
        case .Album(text: _, type: _, _):
            let albumCell = tableView.cellForRow(at: indexPath) as! AlbumTableViewCell
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let albumPage = storyboard.instantiateViewController(withIdentifier:"albumPage") as! AlbumPageViewController
            
            albumPage.id = albumCell.id
            albumPage.albumImage = albumCell.albumCover.image
            self.navigationController?.pushViewController(albumPage, animated: true)
        }
    }
    
    func resize() {
        if AppState.shared.playerShowing {
            let insets = UIEdgeInsetsMake(0, 0, 64, 0)
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
        }
    }
    
    func makeTrackCell(page:FullTrackPage, indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackTableViewCell
        let track = page.items[indexPath.row]
        
        cell.track = track
        cell.configureCell()
        
        // Load next page after loading current last cell
        if indexPath.row == page.items.count - 1, let next = page.next {
            Alamofire.request(next).responseJSON { response in
                switch response.result {
                case .success(let json):
                    let JSON = json as! NSDictionary
                    if let responsePage = FullTrackPage.from(JSON) {
                        page.items.append(contentsOf: responsePage.items.removeDuplicates())
                        page.next = responsePage.next
                    } else if let responsePage = FullTrackPage.from(JSON["tracks"] as! NSDictionary) {
                        page.items.append(contentsOf: responsePage.items.removeDuplicates())
                        page.next = responsePage.next
                    }
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        return cell
    }
    
    func makeArtistCell(page:FullArtistPage, indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath) as! ArtistTableViewCell
        let artist = page.items[indexPath.row]
        
        cell.artist = artist
        cell.configureCell()
   
        // Load next page after loading current last cell
        if indexPath.row == page.items.count - 1, let next = page.next {
            Alamofire.request(next).responseJSON { response in
                switch response.result {
                case .success(let json):
                    let JSON = json as! NSDictionary
                    if let responsePage = FullArtistPage.from(JSON) {
                        page.items.append(contentsOf: responsePage.items.removeDuplicates())
                        page.next = responsePage.next
                    } else if let responsePage = FullArtistPage.from(JSON["artists"] as! NSDictionary) {
                        page.items.append(contentsOf: responsePage.items.removeDuplicates())
                        page.next = responsePage.next
                    }
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        return cell
    }
    
    func makeAlbumCell(page:SimpleAlbumPage, indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! AlbumTableViewCell
        let album = page.items[indexPath.row]
        if album.images.count > 0 {
            Alamofire.request(album.images[0].url).responseData { response in
                if let data = response.data {
                    let image:UIImage = UIImage(data: data)!
                    cell.albumCover.image = image
                }
            }
        }
        cell.albumName.text = album.name
        cell.artistName.text = album.artists.map{$0.name}.joined(separator: ",")
        cell.id = album.id
        
        // Load next page after loading current last cell
        if indexPath.row == page.items.count - 1, let next = page.next {
            Alamofire.request(next).responseJSON { response in
                switch response.result {
                case .success(let json):
                    print("NEW DATA")
                    let JSON = json as! NSDictionary
                    if let responsePage = SimpleAlbumPage.from(JSON) {
                        page.items.append(contentsOf: responsePage.items.removeDuplicates())
                        page.next = responsePage.next
                    } else if let responsePage = SimpleAlbumPage.from(JSON["albums"] as! NSDictionary) {
                        page.items.append(contentsOf: responsePage.items.removeDuplicates())
                        page.next = responsePage.next
                    }
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        return cell
    }

}
