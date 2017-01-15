//
//  AlbumCollectionDatasource.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/31/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import Alamofire

class AlbumCollectionModel:NSObject, UICollectionViewDataSource {
    
    let albums:[SimpleAlbum]
    
    init(albums:[SimpleAlbum]) {
        self.albums = albums
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as!
        AlbumCollectionViewCell
        let album = self.albums[indexPath.row]
        if album.images.count > 0 {
            Alamofire.request(album.images[0].url).responseData { response in
                if let data = response.data {
                    let image:UIImage = UIImage(data: data)!
                    cell.albumImage.image = image
                }
            }
        }
        cell.albumTitle.text = album.name
        cell.album = album
        
        cell.backgroundColor = tableGray
        cell.albumTitle.textColor = .white
        return cell
    }
    
}
