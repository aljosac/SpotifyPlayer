//
//  AlbumTableViewCell.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/9/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import Alamofire

class AlbumTableViewCell: ResultTableViewCell {

    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    var playlist:SimplePlaylist?
    var album:SimpleAlbum?
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
    
    func configureCell() {
        if let album = self.album {
            self.albumName.text = album.name
            self.artistName.text = album.artists.map{$0.name}.joined(separator: ",")
            if (album.images.count) > 0 {
                Alamofire.request(album.images[0].url).responseData { response in
                    if let data = response.data {
                        let image:UIImage = UIImage(data: data)!
                        self.albumCover.image = image
                    }
                }
                
            }
        }
        if let playlist = self.playlist {
            self.albumName.text = playlist.name
            self.artistName.text = playlist.uid
            if (playlist.images.count) > 0 {
                Alamofire.request(playlist.images.first!.url).responseData { response in
                    if let data = response.data {
                        let image:UIImage = UIImage(data: data)!
                        self.albumCover.image = image
                        self.playlist?.images[0].image = image
                    }
                }
                
            }
        }
        
        self.albumName.textColor = .white
        self.artistName.textColor = .white
        self.backgroundColor = tableGray
        self.layoutIfNeeded()
    }
    
}
