//
//  SpotifySearchCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/8/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class SpotifySearchCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var sublabel: UILabel!
    
    var track:Track? = nil
    var albumImage:UIImage? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
