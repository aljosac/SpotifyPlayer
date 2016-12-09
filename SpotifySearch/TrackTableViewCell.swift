//
//  TrackTableViewCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/8/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class TrackTableViewCell: ResultTableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var sublabel: UILabel!
    
    var track:Track? = nil
    var albumImage:UIImage? = nil
    var type:QueueLocation? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellType = .TrackCell
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
