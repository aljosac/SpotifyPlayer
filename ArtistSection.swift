//
//  ArtistSection.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/7/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import RxDataSources

struct ArtistSection {
    var header: String
    var artists:[ArtistItem]
    var updated: Date
    
    init(header:String,artists:[ArtistItem],updated:Date) {
        self.header = header
        self.artists = artists
        self.updated = updated
    }
}

struct ArtistItem {
    let artist:FullArtist
    let date:Date
}


extension ArtistSection: AnimatableSectionModelType {
    typealias Item = ArtistItem
    typealias Identity = String
    
    var identity: String {
        return header
    }
    
    var items:[ArtistItem] {
        return artists
    }
    
    init(original: ArtistSection, items:[Item]) {
        self = original
        self.artists = items
    }
}

extension ArtistSection: CustomDebugStringConvertible {
    var debugDescription: String {
        return "NumberSection(header: \"\(self.header)\", numbers: \(artists.debugDescription), updated: date)"
    }
}

extension ArtistItem: IdentifiableType, Equatable {
    typealias Identity = FullArtist
    
    var identity:FullArtist {
        return artist
    }
    
    static func == (lhs:ArtistItem, rhs:ArtistItem) -> Bool {
        return lhs.artist == rhs.artist && lhs.date == rhs.date
    }
    
}

extension ArtistItem: CustomStringConvertible {
    
    var description: String {
        return "\(artist.name)"
    }
}




