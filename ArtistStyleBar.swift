//
//  ArtistStyleBar.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/1/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation


class ArtistStyleBar: BLKFlexibleHeightBar {
    
    var artist:FullArtist
    
    init(frame: CGRect,artist:FullArtist) {
        self.artist = artist
        super.init(frame: frame)
        self.configureBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureBar(){
        self.maximumBarHeight = self.frame.height / 2
        self.minimumBarHeight = 65.0
        self.backgroundColor = UIColor.blue
        
        // Set name label
        let name:UILabel = UILabel.init()
        name.text = artist.name
        name.textColor = UIColor.white
        name.font = UIFont.systemFont(ofSize: 22.0)
        
    }
    
    
}
