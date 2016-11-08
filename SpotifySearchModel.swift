//
//  SpotifySearchModel.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 9/20/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import Moya
import RxSwift

struct SpotifySearchModel {
    let provider: RxMoyaProvider<Spotify>
    
    func search(query:String) -> Observable<[Track]> {
        return self.provider.request(Spotify.Track(name: query)).debug().mapArray(type: Track.self, keyPath: "tracks.items")
        
    }
    
    func getAlbum(id: String) -> Observable<FullAlbum?> {
        return self.provider.request(Spotify.Album(id: id))
            .debug()
            .mapObjectOptional(type: FullAlbum.self)
    }
    
    func searchArtist(query: String) -> Observable<FullArtist?> {
        return self.provider.request(Spotify.Artist(id: query))
            .debug()
            .mapObjectOptional(type: FullArtist.self)
    }
}
