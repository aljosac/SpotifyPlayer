//
//  AlbumPageModel.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/22/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import RxDataSources

enum AlbumPageSectionModel {
    case TrackSection(items:[AlbumItem])
}

enum AlbumItem {
    case AlbumTrack(track:Track)
}

extension AlbumPageSectionModel: SectionModelType {
    typealias Item = AlbumItem
    
    var items: [AlbumItem] {
        switch self {
        case .TrackSection(items: let items):
            return items.map {$0}
        }
    }
    
    init(original: AlbumPageSectionModel, items: [Item]) {
        switch original {
        case .TrackSection(items: _):
            self = .TrackSection(items: items)
        }
    }
}
