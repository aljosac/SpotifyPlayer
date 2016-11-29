//
//  TrackSection.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/28/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import RxDataSources

struct TrackSection {
    var header: String
    
    var tracks:[TrackItem]
    
    var updated: Date
    
    init(header:String,tracks:[TrackItem],updated:Date) {
        self.header = header
        self.tracks = tracks
        self.updated = updated
    }
}

struct TrackItem {
    let track:Track
    let date:Date
}

extension TrackSection: AnimatableSectionModelType {
    typealias Item = TrackItem
    typealias Identity = String
    
    var identity: String {
        return header
    }
    
    var items:[TrackItem] {
        return tracks
    }
    
    init(original: TrackSection, items:[Item]) {
        self = original
        self.tracks = items
    }
}

extension TrackSection: CustomDebugStringConvertible {
    var debugDescription: String {
        return "NumberSection(header: \"\(self.header)\", numbers: \(tracks.debugDescription), updated: date)"
    }
}

extension TrackItem: IdentifiableType, Equatable {
    typealias Identity = Track
    
    var identity:Track {
        return track
    }
    
    static func == (lhs:TrackItem, rhs:TrackItem) -> Bool {
        return lhs.track == rhs.track && lhs.date == rhs.date
    }
    
}

extension TrackItem
: CustomStringConvertible {
    
    var description: String {
        return "\(track.name)"
    }
}




