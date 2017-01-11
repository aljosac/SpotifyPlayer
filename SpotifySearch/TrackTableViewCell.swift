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
    
    var track:FullTrack? = nil
    var id:String? = nil
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
    
    func configureCell() {
        self.mainLabel.text = track?.name
        self.mainLabel.textColor = .white
        self.sublabel.text = track?.artists.map{ $0.name }.joined(separator: ",")
        self.sublabel.textColor = .white
        self.backgroundColor = tableGray
        self.tintColor = appGreen
        
        // Using resuable cell must reset accessory type
        self.accessoryType = .none
        if AppState.shared.queueIds.contains((track?.id)!) {
            self.accessoryType = .checkmark
        }
    }
    
}
