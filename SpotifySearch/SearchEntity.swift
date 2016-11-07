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
    let album: Album
    
    init(map: Mapper) throws {
        try name = map.from("name")
        try uri = map.from("uri")
        try populatrity = map.from("populatrity")
        try album = map.from("album")
        artist = map.optionalFrom("artists") ?? []
        
    }
}

struct Artist: Mappable {
    
    let name:String
    let id:String
    
    init(map: Mapper) throws {
        try name = map.from("name")
        try id = map.from("uri")
    }
}


struct FullArtist: Mappable {
    
    let name:String
    
    init(map: Mapper) throws {
        try name = map.from("name")
        
    }
}

struct Album: Mappable {
    let name:String
    
    init(map: Mapper) throws {
        try name = map.from("name")
    }
}

struct Test: Mappable {
    let total:Int
    let href:String
    init(map: Mapper) throws {
        try total = map.from("tracks.total")
        try href = map.from("tracks.href")
    }
    
}
