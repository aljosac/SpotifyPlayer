//
//  QueueTableViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/15/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class QueueTableViewController: UITableViewController {

    var disposeBag = DisposeBag()
    
    var queue:Variable<[Track]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.register(UINib(nibName: "SpotifySearchCell", bundle: nil ), forCellReuseIdentifier: "queueCell")
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        queue.asObservable().bindTo(self.tableView.rx.items(cellIdentifier: "queueCell", cellType: SpotifySearchCell.self)) {
            (_,track,cell) in
                print("IM BINDING!!!")
                cell.mainLabel.text = track.name
                cell.sublabel.text = track.artists[0].name + " - " + "\(track.album.name)"
                cell.track = track
        }.addDisposableTo(disposeBag)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
