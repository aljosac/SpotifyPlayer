//
//  TrackEntity.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/3/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Mapper

struct Track: Mappable {
    
    let name: String
    let popularity: Int
    let id:String
    let artists:[SimpleArtist]
    let album:SimpleAlbum
    let uri:String
    init(map: Mapper) throws {
        try name = map.from("name")
        try popularity = map.from("popularity")
        try id = map.from("id")
        try artists = map.from("artists")
        try album = map.from("album")
        try uri = map.from("uri")
    }
}

extension Track: Hashable {
    var hashValue: Int {
        return id.hash
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
}

// Done
struct SimpleArtist: Mappable {
    
    let name:String
    let id:String
    
    init(map: Mapper) throws {
        try name = map.from("name")
        try id = map.from("id")
    }
}

struct FullArtist: Mappable {
    
    let name:String
    let images:[Image]
    init(map: Mapper) throws {
        try name = map.from("name")
        try images = map.from("images")
        
    }
}

struct Image: Mappable {
    let height:Int
    let width:Int
    let url:String
    init(map: Mapper) throws {
        try height = map.from("height")
        try width = map.from("width")
        try url = map.from("url")
    }
}


struct SimpleAlbum: Mappable {
    let name:String
    let type:String
    let id:String
    init(map: Mapper) throws {
        try name = map.from("name")
        try type = map.from("type")
        try id = map.from("id")
    }
}

struct FullAlbum: Mappable {
    let name:String
    
    init(map: Mapper) throws {
        try name = map.from("name")
    }
}

struct Result: Mappable {
    let total:Int
    let href:String
    let tracks:[Track]
    init(map: Mapper) throws {
        try total = map.from("tracks.total")
        try href = map.from("tracks.href")
        try tracks = map.from("tracks.items")
    }
    
}
