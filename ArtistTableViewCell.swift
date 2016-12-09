//
//  ArtistTableViewCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/8/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class ArtistTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        artistImage.layer.cornerRadius = 18
        artistImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
