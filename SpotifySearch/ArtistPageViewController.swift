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
import Mapper

class ArtistPageViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle:UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    var artistBar:ArtistStyleBar? = nil
    var artist:FullArtist?
    var delegateSplitter:BLKDelegateSplitter? = nil
    
    var albums:AlbumCollectionModel? = nil
    var singles:AlbumCollectionModel? = nil
    
    let provider = RxMoyaProvider<Spotify>()
    var disposeBag = DisposeBag()
    let sections:Variable<[ArtistPageSectionModel]> = Variable([.TopTracksSection(items: []),.AlbumsSection(items: []),
                                                                .SinglesSection(items: [])])
    
    init(artist:FullArtist) {
        self.artist = artist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.artist = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Do any additional setup after loading the view.
        let artistRect:CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 300)
        self.artistBar = ArtistStyleBar(frame: artistRect, artist: artist!)
        
        let behavior:BarBehavior = BarBehavior()
        behavior.addSnappingPositionProgress(0.0, forProgressRangeStart: 0.0, end: 0.5)
        behavior.addSnappingPositionProgress(1.0, forProgressRangeStart: 0.5, end: 1.0)
        behavior.isSnappingEnabled = true
        behavior.isElasticMaximumHeightAtTop = true
        self.artistBar?.behaviorDefiner = behavior
        
        delegateSplitter = BLKDelegateSplitter(firstDelegate: behavior, secondDelegate: self)
        self.tableView.delegate = self.delegateSplitter
        
        self.view.addSubview(self.artistBar!)
        
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 10, y: 25, width: 30, height: 30)
        backButton.tintColor = .white
        backButton.setImage(#imageLiteral(resourceName: "BackArrow"), for: .normal)
        backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.artistBar?.addSubview(backButton)
        
        self.tableView.register(UINib(nibName: "TrackTableViewCell", bundle:nil),forCellReuseIdentifier: "trackCell")
        self.tableView.register(UINib(nibName: "AlbumCollectionTableViewCell", bundle:nil),forCellReuseIdentifier: "albumsCell")
        self.tableView.register(ExpandTableViewCell.self, forCellReuseIdentifier: "expandCell")

        
        let playerHeight:CGFloat = AppState.shared.playerShowing ? 64.0 : 0.0
        let insets = UIEdgeInsetsMake(self.artistBar!.maximumBarHeight, 0.0, 50+playerHeight, 0.0)
        
        self.tableView.contentInset = insets
        self.tableView.scrollIndicatorInsets = insets
        self.tableView.indicatorStyle = .white
        self.tableView.backgroundColor = tableGray
        
        // Request info for UITableView
        getSections()
        self.tableView.dataSource = nil
        let datasource = RxTableViewSectionedReloadDataSource<ArtistPageSectionModel>()
        artistPageDataSource(datasource:datasource)
        self.sections.asObservable().bindTo(self.tableView.rx.items(dataSource: datasource)).addDisposableTo(disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        super.viewWillAppear(animated)
    }
    
    func getSections() {
        let spotifyModel = SpotifyModel(provider: provider)
        
        spotifyModel.getTopArtistTracks(id: artist!.id).subscribe { event in
            switch event {
            case let .next(trackList):
                let topArtists = trackList.map{SearchItem.TrackItem(track: $0)}
                self.sections.value[0] = ArtistPageSectionModel.TopTracksSection(items: topArtists)
            case .error,.completed:
                break
            }
        }.addDisposableTo(disposeBag)
        
        spotifyModel.getArtistAlbums(id: artist!.id).subscribe { event in
            switch event {
            case var .next(albumList):
                print(albumList.count)
                let singleList = albumList.branch(eval: {$0.type == "single" }).removeDuplicates()
                print(albumList.count)
                let prunnedAlbums = albumList.removeDuplicates()
                let albums = SearchItem.AlbumItem(album: prunnedAlbums)
                let singles = SearchItem.SingleItem(single: singleList)
                
                self.albums = AlbumCollectionModel(albums: prunnedAlbums)
                self.singles = AlbumCollectionModel(albums: singleList)
                
                self.sections.value[1] = ArtistPageSectionModel.AlbumsSection(items: [albums,SearchItem.EndCell(text: albumText,album:prunnedAlbums)])
                self.sections.value[2] = ArtistPageSectionModel.SinglesSection(items: [singles,SearchItem.EndCell(text: singleText,album:singleList)])
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
                cell.name.textColor = .white
                cell.artist = artist
                cell.backgroundColor = tableGray
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
                cell.mainLabel.textColor = .white
                cell.sublabel.textColor = .white
                cell.track = track
                cell.backgroundColor = tableGray
                cell.tintColor = appGreen
                
                if AppState.shared.queueIds.contains(track.id) {
                    cell.accessoryType = .checkmark
                }
                return cell
            case let .AlbumItem(album):
                let cell = table.dequeueReusableCell(withIdentifier: "albumsCell", for: idxPath) as! AlbumCollectionTableViewCell
                cell.albumCollection.delegate = self
                cell.albumCollection.dataSource = self.albums
                cell.albumCollection.register(UINib( nibName: "AlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "albumCell")
                cell.backgroundColor = tableGray
                cell.albumCollection.backgroundColor = tableGray
                cell.albums = album
                return cell
            case let .SingleItem(single):
                let cell = table.dequeueReusableCell(withIdentifier: "albumsCell", for: idxPath) as! AlbumCollectionTableViewCell
                cell.albumCollection.delegate = self
                cell.albumCollection.dataSource = self.singles
                cell.albumCollection.register(UINib( nibName: "AlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "albumCell")
                cell.backgroundColor = tableGray
                cell.albumCollection.backgroundColor = tableGray
                cell.albums = single
                return cell
            case let .EndCell(text,albums):
                let cell = table.dequeueReusableCell(withIdentifier: "expandCell", for: idxPath) as! ExpandTableViewCell
                cell.textLabel?.text = text
                cell.textLabel?.textColor = .white
                cell.backgroundColor = tableGray
                cell.accessoryType = .disclosureIndicator
                cell.albums = albums
                cell.cellType = .ExpandCell
                return cell
            default:
                return UITableViewCell()
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
    
    func close() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .center
        header.textLabel?.textColor = UIColor.white
        header.contentView.backgroundColor = tableGray
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1,2:
            if indexPath.row == 1 {
                return 44
            }
            if let albums = self.albums {
                let smaller = CGFloat(min(albums.albums.count,4))
                let rows:CGFloat = ceil(smaller/2.0)
                return (rows * 215.0)
            }
            if let singles = self.singles {
                let smaller = CGFloat(min(singles.albums.count,4))
                let rows:CGFloat = ceil(smaller/2.0)
                return (rows * 215.0)
            }
            return 210
        default:
            return 44
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ResultTableViewCell {
            switch cell.cellType! {
            case .TrackCell:
                let trackCell = cell as! TrackTableViewCell
                print("posting")
                cell.accessoryType = .checkmark
                NotificationCenter.default.post(name: Notification.Name("addTrack"), object: nil, userInfo: ["track":trackCell.track!])
                let insets = UIEdgeInsetsMake(self.artistBar!.maximumBarHeight+20, 0.0, 50+64, 0.0)
                
                self.tableView.contentInset = insets
                self.tableView.scrollIndicatorInsets = insets
            case .ExpandCell:
                let expandCell = cell as! ExpandTableViewCell
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let expandController = storyboard.instantiateViewController(withIdentifier: "expandPage") as! ExpandTableViewController
                expandController.data = expandCell.albums!
                self.navigationController?.pushViewController(expandController, animated: true)
            default:
                return
            }
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


// MARK: - CollectionViewDelegate


extension ArtistPageViewController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 15, 5, 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as!
        AlbumCollectionViewCell
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let albumPage = storyboard.instantiateViewController(withIdentifier: "albumPage") as! AlbumPageViewController
        
        albumPage.albumImage = cell.albumImage.image
        albumPage.id = cell.albumID
        self.navigationController?.pushViewController(albumPage, animated: true)
    }
}


// MARK: - ArtistTableViewSectionModel
enum ArtistSectionModel {
    case TopTrackSection(items:[SearchItem])
    case Albums(items:[SearchItem])
}

extension ArtistPageViewController: UIGestureRecognizerDelegate {}



