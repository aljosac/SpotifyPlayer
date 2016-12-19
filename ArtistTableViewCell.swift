//
//  ArtistTableViewCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/8/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class ArtistTableViewCell: ResultTableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    
    var artist:FullArtist? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        artistImage.layer.cornerRadius = 20
        artistImage.layer.masksToBounds = true
        self.cellType = .ArtistCell
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
