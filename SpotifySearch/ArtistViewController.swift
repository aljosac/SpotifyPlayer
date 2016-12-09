//
//  ArtistViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/9/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class ArtistViewController: UITableViewController {

    var artistBar:ArtistStyleBar? = nil
    var artist:FullArtist? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let artistRect:CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 100)
        self.artistBar = ArtistStyleBar(frame: artistRect, artist: artist!)
        
        // Do any additional setup after loading the view.
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
