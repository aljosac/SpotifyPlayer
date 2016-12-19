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
        self.maximumBarHeight = 300
        self.minimumBarHeight = 65.0
        self.backgroundColor = UIColor.darkGray
        
        let artistImage = artist.images.first?.image
        
        if let image = artistImage {
            
            
            let backgroundImageView = UIImageView(image: image)
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.clipsToBounds = true
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            
            
            let startBackgroundAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes =
                BLKFlexibleHeightBarSubviewLayoutAttributes()
            startBackgroundAttribute.bounds = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            startBackgroundAttribute.center = CGPoint(x: self.frame.width*0.5, y: self.minimumBarHeight*0.5 )
            backgroundImageView.add(startBackgroundAttribute, forProgress: 0.0)
            blurView.add(startBackgroundAttribute, forProgress: 0.0)
            
            
            let endBackgroundAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes =
                BLKFlexibleHeightBarSubviewLayoutAttributes(existing: startBackgroundAttribute)
            endBackgroundAttribute.bounds = CGRect(x: 0, y: 0, width: self.frame.width, height: self.minimumBarHeight)
            startBackgroundAttribute.center = CGPoint(x: self.frame.width*0.5, y: self.frame.height*0.5)
            backgroundImageView.add(endBackgroundAttribute, forProgress: 1.0)
            blurView.add(endBackgroundAttribute, forProgress: 1.0)
            
            self.addSubview(backgroundImageView)
            self.addSubview(blurView)
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 50
            
            let startImageAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes =
                BLKFlexibleHeightBarSubviewLayoutAttributes()
            startImageAttribute.size = CGSize(width: 100.0, height: 100.0)
            startImageAttribute.center = CGPoint(x: self.frame.width*0.5, y: self.maximumBarHeight-150)
            imageView.add(startImageAttribute, forProgress: 0.0)
            
            
            let midImageAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes =
                BLKFlexibleHeightBarSubviewLayoutAttributes(existing: startImageAttribute)
            midImageAttribute.center = CGPoint(x: self.frame.width*0.5, y: (self.maximumBarHeight-self.minimumBarHeight)*0.8+self.minimumBarHeight-110.0)
            imageView.add(midImageAttribute, forProgress: 0.2)
            
            let endImageAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes =
                BLKFlexibleHeightBarSubviewLayoutAttributes(existing: midImageAttribute)
            endImageAttribute.center = CGPoint(x: self.frame.width*0.5, y: (self.maximumBarHeight-self.minimumBarHeight)*0.64+self.minimumBarHeight-110.0)
            endImageAttribute.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            endImageAttribute.alpha = 0.0
            imageView.add(endImageAttribute, forProgress: 0.5)
            
            self.addSubview(imageView)
        }
        
        
        
        // Set name label
        let name:UILabel = UILabel.init()
        name.text = artist.name
        name.textColor = UIColor.white
        name.font = UIFont.boldSystemFont(ofSize: 27.0)
    
        
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
