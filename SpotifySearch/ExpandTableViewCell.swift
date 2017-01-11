//
//  ExpandTableViewCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/30/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class ExpandTableViewCell: ResultTableViewCell {

    var info:EndCell? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cellType = .ExpandCell
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
