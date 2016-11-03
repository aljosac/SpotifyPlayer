//
//  TrackEntity.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/3/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Mapper

struct Track: Mappable {
    
    let populatrity: Int
    let name: String
    let uri: String
    let artist: [Artist]?
    
    init(map: Mapper) throws {
        try name = map.from("name")
        try uri = map.from("uri")
        try populatrity = map.from("populatrity")
        artist = map.optionalFrom("artists") ?? []
    }
}

struct Artist: Mappable {
    
    let name:String
    let uri:String
    
    init(map: Mapper) throws {
        try name = map.from("name")
        try uri = map.from("uri")
    }
}
