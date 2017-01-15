//
//  PlaylistPageViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/20/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import Alamofire

class PlaylistPageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    override var preferredStatusBarStyle:UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    var loader:SimplePlaylist?
    var tracks:FullPlaylistPage?
    var albumBar:AlbumStyleBar? = nil
    var disposeBag = DisposeBag()
    var delegateSplitter:BLKDelegateSplitter? = nil
    
    init(loader:SimplePlaylist) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = UITableView(frame: self.view.bounds)
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TrackTableViewCell", bundle:nil),forCellReuseIdentifier: "trackCell")
        tableView.indicatorStyle = .white
        tableView.separatorColor = tableGray
        tableView.backgroundColor = tableGray
        self.view.addSubview(tableView)

        
        let albumRect:CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 300)

        let activityView = UIActivityIndicatorView(frame: self.view.frame)
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        let spotifyModel = SpotifyModel(provider: AppState.shared.provider)
        spotifyModel.getPlaylist(loader: loader!).subscribe{ event in
            switch event {
            case let .next(playlist):
                print("receaved request")
                self.tracks = playlist.tracks
    
                self.albumBar = AlbumStyleBar(frame: albumRect, name: playlist.name,image: self.loader?.images.first?.image)
                let behavior:BarBehavior = BarBehavior()
                behavior.addSnappingPositionProgress(0.0, forProgressRangeStart: 0.0, end: 0.5)
                behavior.addSnappingPositionProgress(1.0, forProgressRangeStart: 0.5, end: 1.0)
                behavior.isSnappingEnabled = true
                behavior.isElasticMaximumHeightAtTop = true
                
                self.albumBar?.behaviorDefiner = behavior
                self.delegateSplitter = BLKDelegateSplitter(firstDelegate: behavior, secondDelegate: self)
                tableView.delegate = self.delegateSplitter
              
                self.view.addSubview(self.albumBar!)
                
                let playerHeight:CGFloat = AppState.shared.playerShowing ? 64.0 : 0.0
                let insets = UIEdgeInsetsMake(self.albumBar!.maximumBarHeight, 0.0, 50+playerHeight, 0.0)
                
                tableView.contentInset = insets
                tableView.scrollIndicatorInsets = insets
                
                let backButton = UIButton(type: .custom)
                backButton.frame = CGRect(x: 10, y: 25, width: 30, height: 30)
                backButton.tintColor = .white
                backButton.setImage(#imageLiteral(resourceName: "BackArrow"), for: .normal)
                backButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
                self.albumBar?.addSubview(backButton)
                
                tableView.reloadData()
                
                activityView.stopAnimating()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func close() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.tracks?.items.count ?? 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackTableViewCell
        let track = tracks?.items[indexPath.row].track
        
        cell.track = track
        cell.configureCell()
        
        // Load next page after loading current last cell
        if indexPath.row == tracks!.items.count - 1, let next = tracks?.next {
            Alamofire.request(next).responseJSON { response in
                switch response.result {
                case .success(let json):
                    let JSON = json as! NSDictionary
                    if let responsePage = FullPlaylistPage.from(JSON) {
                        self.tracks!.items.append(contentsOf: responsePage.items)
                        self.tracks!.next = responsePage.next
                    } else if let responsePage = FullPlaylistPage.from(JSON["tracks"] as! NSDictionary) {
                        self.tracks!.items.append(contentsOf: responsePage.items)
                        self.tracks!.next = responsePage.next
                    }
                    tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        return cell
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ResultTableViewCell
        switch cell.cellType! {
        case .TrackCell:
            let trackCell = cell as! TrackTableViewCell
            print("posting")
            NotificationCenter.default.post(name: Notification.Name("addTrack"), object: nil, userInfo: ["track":trackCell.track!])
            let insets = UIEdgeInsetsMake(self.albumBar!.maximumBarHeight, 0.0, 50+64, 0.0)
            
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}


extension PlaylistPageViewController: UIGestureRecognizerDelegate {}
