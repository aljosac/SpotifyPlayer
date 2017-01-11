//
//  SearchModels.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/8/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import RxDataSources

//MARK: Search Home Section Model

enum SearchHomeSectionModel {
    case HistorySection(items:[SectionItem])
    case TopArtistsSection(items:[SectionItem])
}

enum SectionItem {
    case HistorySectionItem(title:String)
    case TopArtistSectionItem(artist:FullArtist)
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

//MARK: Search Result Section Model

enum SearchResultSectionModel {
    case TrackSection(items:[SearchItem])
    case ArtistSection(items:[SearchItem])
    case AlbumSection(items:[SearchItem])
    case TopResultSection(items:[SearchItem])
}

enum EndCell {
    case Album(text:String,type:String,page:SimpleAlbumPage)
    case Track(text:String,page:FullTrackPage)
    case Artist(text:String,page:FullArtistPage)
}

enum SearchItem {
    case TrackItem(track:FullTrack)
    case ArtistItem(artist:FullArtist)
    case AlbumItem(album:[SimpleAlbum])
    case SingleItem(single:[SimpleAlbum])
    case SearchAlbumItem(album:SimpleAlbum)
    case ExpandItem(type:EndCell)
}

extension SearchResultSectionModel: SectionModelType {
    typealias Item = SearchItem
    
    var items: [SearchItem] {
        switch self {
        case .TrackSection(items: let items):
            return items.map {$0}
        case .ArtistSection(items: let items):
            return items.map {$0}
        case .AlbumSection(items: let items):
            return items.map {$0}
        case .TopResultSection(items: let items):
            return items.map {$0}
        }
    }
    
    init(original: SearchResultSectionModel, items: [Item]) {
        switch original {
        case .TrackSection(items: _):
            self = .TrackSection(items: items)
        case .ArtistSection(items: _):
            self = .ArtistSection(items: items)
        case .AlbumSection(items: _):
            self = .AlbumSection(items: items)
        case .TopResultSection(items: _):
            self = .TopResultSection(items: items)
        }
    }
}

extension SearchResultSectionModel {
    var title:String {
        switch self {
        case .TrackSection(items: _):
            return "Tracks"
        case .ArtistSection(items: _):
            return "Artists"
        case .AlbumSection(items: _):
            return "Albums"
        case .TopResultSection(items: _):
            return "Top Result"
        }
    }
}

