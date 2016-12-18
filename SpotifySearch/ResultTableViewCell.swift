//
//  ResultTableViewCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/18/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    var cellType:ResultCellType? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

enum ResultCellType {
    case TrackCell
    case ArtistCell
    case AlbumCell
    case HistoryCell
}
