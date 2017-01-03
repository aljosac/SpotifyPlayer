//
//  ArtistStyleBar.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/1/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation


class AlbumStyleBar: BLKFlexibleHeightBar {
    
    var album:FullAlbum
    var image:UIImage?
    init(frame: CGRect,album:FullAlbum,image:UIImage?) {
        self.album = album
        self.image = image
        super.init(frame: frame)
        self.configureBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureBar(){
        self.maximumBarHeight = 300
        self.minimumBarHeight = 65.0
        self.backgroundColor = tableGray
        
        
        if let image = self.image {
            
            // BACKGROUND
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
            
            // ALBUM COVER
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            let bounds = imageView.bounds
            
            let startImageAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes =
                BLKFlexibleHeightBarSubviewLayoutAttributes()
            startImageAttribute.size = CGSize(width: 150, height: 150)
            startImageAttribute.center = CGPoint(x: self.frame.width*0.5, y: self.maximumBarHeight-150)
            imageView.add(startImageAttribute, forProgress: 0.0)
            
            let midImageAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes =
                BLKFlexibleHeightBarSubviewLayoutAttributes(existing: startImageAttribute)
            midImageAttribute.size = CGSize(width: 100.0, height: 100.0)
            midImageAttribute.center = CGPoint(x: self.frame.width*0.5, y: self.maximumBarHeight-150)
            imageView.add(midImageAttribute, forProgress: 0.3)
            
            let endImageAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes =
                BLKFlexibleHeightBarSubviewLayoutAttributes(existing: midImageAttribute)
            endImageAttribute.size = CGSize(width: 100.0, height: 100.0)
            endImageAttribute.center = CGPoint(x: self.frame.width*0.5, y: self.maximumBarHeight-150)
            endImageAttribute.bounds = CGRect(x: bounds.origin.x ,
                                              y: bounds.origin.y,
                                              width: 100, height: 0)
            imageView.add(endImageAttribute, forProgress: 0.6)
            
            self.addSubview(imageView)
        }
        
        
        
        // TITLE LABEL
        let name:UILabel = UILabel.init()
        name.text = album.name
        name.textColor = UIColor.white
        name.adjustsFontSizeToFitWidth = true
        name.textAlignment = .center
        name.font = UIFont.boldSystemFont(ofSize: 27.0)
    
        let startNameAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes = BLKFlexibleHeightBarSubviewLayoutAttributes()
        startNameAttribute.size = CGSize(width: self.frame.width - 20, height: 30)
        startNameAttribute.center = CGPoint(x: Double(self.frame.size.width) * 0.5, y: Double(self.maximumBarHeight) - 40)
        name.add(startNameAttribute, forProgress: 0.0)
        
        let endNameAttribute = BLKFlexibleHeightBarSubviewLayoutAttributes(existing: startNameAttribute)!
        endNameAttribute.alpha = 0.0
        name.add(endNameAttribute, forProgress: 0.2)
        
        self.addSubview(name)

        
        // HEADER LABEL
        let headerName:UILabel = UILabel.init()
        headerName.text = album.name
        headerName.textColor = UIColor.white
        headerName.font = UIFont.boldSystemFont(ofSize: 15.0)
        headerName.textAlignment = .center
        
        let startHeaderAttribute:BLKFlexibleHeightBarSubviewLayoutAttributes = BLKFlexibleHeightBarSubviewLayoutAttributes()
        startHeaderAttribute.size = name.sizeThatFits(CGSize.zero)
        startHeaderAttribute.center = CGPoint(x: Double(self.frame.size.width) * 0.5, y: Double(self.minimumBarHeight - 25))
        startHeaderAttribute.alpha = 0.0
        headerName.add(startHeaderAttribute, forProgress: 0.0)
        
        let midHeaderAttribute = BLKFlexibleHeightBarSubviewLayoutAttributes.init(existing: startHeaderAttribute)!
        midHeaderAttribute.alpha = 0.0
        headerName.add(midHeaderAttribute, forProgress: 0.2)
        
        let endHeaderAttribute = BLKFlexibleHeightBarSubviewLayoutAttributes(existing: midHeaderAttribute)!
        endHeaderAttribute.alpha = 1.0
        
        headerName.add(endHeaderAttribute, forProgress: 0.8)
        self.addSubview(headerName)
        
    }
    
    
}
