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
        self.maximumBarHeight = 200
        self.minimumBarHeight = 65.0
        self.backgroundColor = UIColor.blue
        
        // Set name label
        let name:UILabel = UILabel.init()
        name.text = artist.name
        name.textColor = UIColor.white
        name.font = UIFont.systemFont(ofSize: 22.0)
        
        // Create Start Attribute
        let startNameAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes = BLKFlexibleHeightBarSubviewLayoutAttributes()
        startNameAttribute.size = name.sizeThatFits(CGSize.zero)
        startNameAttribute.center = CGPoint(x: Double(self.frame.size.width) * 0.5, y: Double(self.maximumBarHeight) - 50)
        name.add(startNameAttribute, forProgress: 0.0)
        
        // Create Mid Attribute
        let midNameAttribute = BLKFlexibleHeightBarSubviewLayoutAttributes.init(existing: startNameAttribute)!
        midNameAttribute.center = CGPoint(x: (self.frame.size.width) * 0.5, y: (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-50.0)
        name.add(midNameAttribute, forProgress: 0.6)
        
        // Create End Attribute
        let endNameAttribute = BLKFlexibleHeightBarSubviewLayoutAttributes(existing: midNameAttribute)!
        endNameAttribute.center = CGPoint(x: self.frame.size.width*0.5, y: self.minimumBarHeight-25.0)
        name.add(endNameAttribute, forProgress: 1.0)
        
        self.addSubview(name)
    }
    
    
}
