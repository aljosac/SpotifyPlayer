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
        return self.provider.request(Spotify.TopArtists).debug().mapArray(type: SimpleArtist.self, keyPath: "items").map(self.upgradeArtistList)
    }
    
    func getArtist(id:String) -> Observable<FullArtist> {
        return self.provider.request(Spotify.Artist(id: id)).debug().mapObject(type: FullArtist.self, keyPath: )
    }
    
    func getTopArtistTracks(id:String) -> Observable<[Track]> {
        print(Spotify.TopArtistTracks(id: id).baseURL.absoluteString + Spotify.TopArtistTracks(id: id).path)
        return self.provider.request(Spotify.TopArtistTracks(id: id)).debug().mapArray(type: Track.self, keyPath:"tracks")
    }
    
    func getArtistAlbums(id:String) -> Observable<[SimpleAlbum]>{
        return self.provider.request(Spotify.ArtistAlbums(id: id)).debug().mapArray(type: SimpleAlbum.self, keyPath:"items")
    }
    
    func upgradeArtistList(artists:[SimpleArtist]) -> [FullArtist] {
        let provider = MoyaProvider<Spotify>()
        let ids:String = artists.map { $0.id }.joined(separator: ",")
        provider.request(Spotify.Artists(id: ids)) { (result) in
            if case .success(let response) = result {
                do {
                    let repos = try response.mapArray(withKeyPath: "artists") as [FullArtist]
                    print(repos)
                } catch Error.jsonMapping(let error) {
                    print(try? error.mapString())
                } catch {
                    print(":(")
                }
            }
        }
    }
}


