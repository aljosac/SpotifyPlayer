//
//  AlbumCollectionViewCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/19/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!

    var album:SimpleAlbum? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        albumImage.contentMode = .scaleToFill
    }

}
