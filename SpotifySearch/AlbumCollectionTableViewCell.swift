//
//  AlbumCollectionTableViewCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/12/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class AlbumCollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var albumCollection: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
