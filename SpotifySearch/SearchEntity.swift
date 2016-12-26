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


struct SimpleTrack: Mappable {
    
    let name: String
    let id:String
    let artists:[SimpleArtist]
    init(map: Mapper) throws {
        try name = map.from("name")
        try id = map.from("id")
        try artists = map.from("artists")
    }
}

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
    var images:[Image]
    let popularity:Int
    let id:String
    
    init(map: Mapper) throws {
        try name = map.from("name")
        try id = map.from("id")
        try images = map.from("images")
        try popularity = map.from("popularity")
    }
}

struct SimpleAlbum: Mappable {
    let name:String
    let type:String
    let id:String
    let images:[Image]
    init(map: Mapper) throws {
        try name = map.from("name")
        try type = map.from("album_type")
        try images = map.from("images")
        try id = map.from("id")
    }
}

struct FullAlbum: Mappable {
    let name:String
    let images:[Image]
    let tracks:[SimpleTrack]
    init(map: Mapper) throws {
        try name = map.from("name")
        try images = map.from("images")
        try tracks = map.from("tracks.items")
    }
}

struct Image: Mappable {
    let height:Int
    let width:Int
    let url:String
    var image:UIImage?
    init(map: Mapper) throws {
        try height = map.from("height")
        try width = map.from("width")
        try url = map.from("url")
        image = nil
    }
}

struct Result:Mappable {
    let tracks:[Track]
    let artists:[FullArtist]
    
    init(map: Mapper) throws {
        try tracks = map.from("tracks.items")
        try artists = map.from("artists.items")
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

extension FullArtist: Hashable {
    var hashValue: Int {
        return id.hash
    }
    
    static func == (lhs: FullArtist, rhs: FullArtist) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SimpleAlbum:Hashable {
    
    var hashValue: Int {
        return name.hash
    }
    
    static func == (lhs: SimpleAlbum, rhs: SimpleAlbum) -> Bool {
        return lhs.name == rhs.name
    }
}

