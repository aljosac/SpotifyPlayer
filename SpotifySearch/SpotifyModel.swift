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
    
    func topArtists() -> Observable<[FullArtist]> {
        return self.provider.request(Spotify.TopArtists).debug().mapArray(type: SimpleArtist.self, keyPath: "items").map { list in list.map{$0.id}.joined(separator: ",")}.flatMap(getArtists(id:))
    }
    
    func getArtist(id:String) -> Observable<FullArtist> {
        return self.provider.request(Spotify.Artist(id: id)).debug().mapObject(type: FullArtist.self)
    }
    
    func getTopArtistTracks(id:String) -> Observable<[Track]> {
        print(Spotify.TopArtistTracks(id: id).baseURL.absoluteString + Spotify.TopArtistTracks(id: id).path)
        return self.provider.request(Spotify.TopArtistTracks(id: id)).debug().mapArray(type: Track.self, keyPath:"tracks")
    }
    
    func getArtistAlbums(id:String) -> Observable<[SimpleAlbum]>{
        return self.provider.request(Spotify.ArtistAlbums(id: id)).debug().mapArray(type: SimpleAlbum.self, keyPath:"items")
    }
    
    func getArtists(id:String) -> Observable<[FullArtist]> {
        return self.provider.request(Spotify.Artists(id: id)).debug().mapArray(type: FullArtist.self, keyPath: "artists")
    }
}


