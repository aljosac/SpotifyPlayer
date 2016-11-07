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
    let query: Observable<String>
    func search() -> Observable<[Track]> {
        return query.observeOn(MainScheduler.instance)
            .flatMapLatest { name -> Observable<[Track]> in
                 self.provider.request(Spotify.Track(name: name)).debug().mapArray(type: Track.self)
            }
    }
    
    func search(name:String) -> Observable<Any> {
        
        return self.provider.request(Spotify.Track(name: name)).debug().mapJSON()
    
    }
    
    func getAlbum(id: String) -> Observable<Album?> {
        return self.provider.request(Spotify.Album(id: id))
            .debug()
            .mapObjectOptional(type: Album.self)
    }
    
    func searchArtist(query: String) -> Observable<FullArtist?> {
        return self.provider.request(Spotify.Artist(id: query))
            .debug()
            .mapObjectOptional(type: FullArtist.self)
    }
}
