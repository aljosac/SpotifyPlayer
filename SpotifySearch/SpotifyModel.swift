//
//  SpotifyModel.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 9/20/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import Moya
import RxSwift

struct SpotifyModel {
    let provider: RxMoyaProvider<Spotify>
    
    func search(query:String) -> Observable<Result> {
        //return self.provider.request(Spotify.Search(name: query)).debug().mapArray(type: Track.self, keyPath: "tracks.items")
        return self.provider.request(Spotify.Search(name: query)).debug().mapObject(type: Result.self)
    }
    
    func topArtists() -> Observable<[SimpleArtist]> {
        return self.provider.request(Spotify.TopArtists).debug().mapArray(type: SimpleArtist.self, keyPath: "items")
    }
    
    
    func getTopArtistTracks(id:String) -> Observable<[Track]> {
        return self.provider.request(Spotify.TopArtistTracks(id: id)).debug().mapArray(type: Track.self, keyPath:"tracks")
    }
    
    func getArtistAlbums(id:String) -> Observable<[SimpleAlbum]>{
        return self.provider.request(Spotify.ArtistAlbums(id: id)).debug().mapArray(type: SimpleAlbum.self, keyPath:"items")
    }
    
}


