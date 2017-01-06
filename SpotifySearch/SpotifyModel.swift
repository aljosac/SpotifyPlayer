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
    
    // Queries Spotify
    func search(query:String) -> Observable<Result> {
        //return self.provider.request(Spotify.Search(name: query)).debug().mapArray(type: Track.self, keyPath: "tracks.items")
        return self.provider.request(Spotify.Search(name: query)).debug().mapObject(type: Result.self)
    }
    
    func getTrack(id:String) -> Observable<FullTrack> {
        return self.provider.request(Spotify.Track(id: id)).debug().mapObject(type: FullTrack.self)
    }
    
    func getTracks(id:String) -> Observable<[FullTrack]> {
        return self.provider.request(Spotify.Tracks(id: id)).debug().mapArray(type: FullTrack.self, keyPath: "tracks")
    }
    // Gets users top artists
    func topArtists() -> Observable<[FullArtist]> {
        return self.provider.request(Spotify.TopArtists).debug().mapArray(type: SimpleArtist.self, keyPath: "items").map { list in list.map{$0.id}.joined(separator: ",")}.flatMap(getArtists(id:))
    }
    // get a singular artist
    func getArtist(id:String) -> Observable<FullArtist> {
        return self.provider.request(Spotify.Artist(id: id)).debug().mapObject(type: FullArtist.self)
    }
    
    // gets multiple artists
    func getArtists(id:String) -> Observable<[FullArtist]> {
        return self.provider.request(Spotify.Artists(id: id)).debug().mapArray(type: FullArtist.self, keyPath: "artists")
    }
    
    func getTopArtistTracks(id:String) -> Observable<[FullTrack]> {
        print(Spotify.TopArtistTracks(id: id).baseURL.absoluteString + Spotify.TopArtistTracks(id: id).path)
        return self.provider.request(Spotify.TopArtistTracks(id: id)).debug().mapArray(type: FullTrack.self, keyPath:"tracks")
    }
    
    func getArtistAlbums(id:String,type:String = "album,single",offset:Int = 0,limit:Int = 10) -> Observable<SimpleAlbumPage>{
        return self.provider.request(Spotify.ArtistAlbums(id:id,type:type,limit:limit,offset:offset)).debug().mapObject(type: SimpleAlbumPage.self)
    }
    
    func getAlbum(id:String) -> Observable<FullAlbum> {
        return self.provider.request(Spotify.Album(id: id)).debug().mapObject(type: FullAlbum.self)
    }
}


