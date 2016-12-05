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
import RxDataSources
struct SpotifySearchModel {
    let provider: RxMoyaProvider<Spotify>
    
    func search(query:String) -> Observable<[Track]> {
        return self.provider.request(Spotify.Track(name: query)).debug().mapArray(type: Track.self, keyPath: "tracks.items")
        
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

enum SearchHomeSectionModel {
    case HistorySection(items:[SectionItem])
    case TopArtistsSection(items:[SectionItem])
}

enum SectionItem {
    case HistorySectionItem(title:String)
    case TopArtistSectionItem(artist:SimpleArtist)
}

extension SearchHomeSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    var items: [SectionItem] {
        switch self {
        case .HistorySection(items: let items):
            return items.map {$0}
        case .TopArtistsSection(items: let items):
            return items.map {$0}
        }
    }
    
    init(original: SearchHomeSectionModel, items: [Item]) {
        switch original {
        case .HistorySection(items: _):
            self = .HistorySection(items: items)
        case .TopArtistsSection(items: _):
            self = .TopArtistsSection(items: items)
        }
    }
}

extension SearchHomeSectionModel {
    var title:String {
        switch self {
        case .HistorySection(items: _):
            return "HISTORY"
        case .TopArtistsSection(items: _):
            return "TOP ARTISTS"
        }
    }
}

