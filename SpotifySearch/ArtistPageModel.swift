//
//  ArtistPageModel.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/9/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import RxDataSources

enum ArtistPageSectionModel {
    case TopTracksSection(items:[SearchItem])
    case AlbumsSection(items:[SearchItem])
    case SinglesSection(items:[SearchItem])
    case RelatedSection(items:[SearchItem])

}

extension ArtistPageSectionModel: SectionModelType {
    typealias Item = SearchItem
    
    var items: [SearchItem] {
        switch self {
        case .TopTracksSection(items: let items):
            return items.map {$0}
        case .AlbumsSection(items: let items):
            return items.map {$0}
        case .SinglesSection(items: let items):
            return items.map {$0}
        case .RelatedSection(items: let items):
            return items.map {$0}
        }
    }
    
    init(original: ArtistPageSectionModel, items: [Item]) {
        switch original {
        case .TopTracksSection(items: _):
            self = .TopTracksSection(items: items)
        case .AlbumsSection(items: _):
            self = .AlbumsSection(items: items)
        case .SinglesSection(items: _):
            self = .SinglesSection(items: items)
        case .RelatedSection(items: _):
            self = .RelatedSection(items: items)
        }
    }
}

extension ArtistPageSectionModel {
    var title:String {
        switch self {
        case .TopTracksSection(items: _):
            return " Top Tracks"
        case .RelatedSection(items: _):
            return " Related Artists"
        case .AlbumsSection(items: _):
            return "Albums"
        case .SinglesSection(items: _):
            return "Singles"
        }
    }
}
