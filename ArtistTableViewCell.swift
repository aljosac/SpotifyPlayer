//
//  ArtistTableViewCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/8/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import Alamofire

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
    
    func configureCell() {
        self.name.text = artist!.name
        self.name.textColor = .white
        self.backgroundColor = tableGray
        if artist!.images.count > 0 {
            Alamofire.request(artist!.images[0].url).responseData { response in
                if let data = response.data {
                    let image:UIImage = UIImage(data: data)!
                    self.artistImage.image = image
                    self.artist?.images[0].image = image

                }
            }
        }
    }
    
}
