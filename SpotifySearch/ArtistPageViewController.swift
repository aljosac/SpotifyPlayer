//
//  ArtistViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/9/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class ArtistPageViewController: UITableViewController {

    var artistBar:ArtistStyleBar? = nil
    var artist:FullArtist? = nil
    var delegateSplitter:BLKDelegateSplitter? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let artistRect:CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 200)
        self.artistBar = ArtistStyleBar(frame: artistRect, artist: artist!)
        
        let behavior:ArtistBarBehavior = ArtistBarBehavior()
        behavior.addSnappingPositionProgress(0.0, forProgressRangeStart: 0.0, end: 0.5)
        behavior.addSnappingPositionProgress(1.0, forProgressRangeStart: 0.5, end: 1.0)
        behavior.isElasticMaximumHeightAtTop = true
        self.artistBar?.behaviorDefiner = behavior
        
        self.view.addSubview(self.artistBar!)
        
        self.tableView.register(UINib(nibName: "TrackTableViewCell", bundle:nil),
                                forCellReuseIdentifier: "trackCell")
        
        
        
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




