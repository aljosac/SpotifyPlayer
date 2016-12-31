//
//  AlbumTableViewCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/9/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class AlbumTableViewCell: ResultTableViewCell {

    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    var id:String? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellType = .AlbumCell
        self.backgroundColor = tableGray
        self.albumName.textColor = .white
        self.artistName.textColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
