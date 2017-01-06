//
//  TrackEntity.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/3/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Mapper



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

struct FullTrack: Mappable {
    
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
    var images:[Image]
    let artists:[SimpleArtist]
    init(map: Mapper) throws {
        try name = map.from("name")
        try type = map.from("album_type")
        try images = map.from("images")
        try id = map.from("id")
        try artists = map.from("artists")
    }
}

struct FullAlbum: Mappable {
    let name:String
    var images:[Image]
    let tracks:SimpleTrackPage
    init(map: Mapper) throws {
        try name = map.from("name")
        try images = map.from("images")
        try tracks = map.from("tracks")
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


enum PageType {
    case SimpleTrack(items:[SimpleTrack])
    case FullTrack(items:[FullTrack])
    case SimpleArtist(items:[SimpleArtist])
    case FullArtist(items:[FullArtist])
    case SimpleAlbum(items:[SimpleAlbum])
    case FullAlbum(items:[FullAlbum])
}

class Page:Mappable {
    let next:String?
    let total:Int
    let limit:Int
    let offset:Int
    required init(map: Mapper) throws {
        next = map.optionalFrom("next")
        try total = map.from("total")
        try limit = map.from("limit")
        try offset = map.from("offset")
    }
    
}

class FullTrackPage: Page {
    
    var items:[FullTrack]
    
    required init(map: Mapper) throws {
        try items = map.from("items")
        try super.init(map: map)
    }
}

class SimpleTrackPage: Page {
    
    var items:[SimpleTrack]
    
    required init(map: Mapper) throws {
        try items = map.from("items")
        try super.init(map: map)
    }
}

class FullArtistPage: Page {     
    
    var items:[FullArtist]
    
    required init(map: Mapper) throws {
        try items = map.from("items")
        try super.init(map: map)
    }
}

class SimpleAlbumPage: Page {
    
    var items:[SimpleAlbum]
    
    required init(map: Mapper) throws {
        try items = map.from("items")
        try super.init(map: map)
    }
}

struct Result:Mappable {
    
    let tracks:FullTrackPage
    let artists:FullArtistPage
    let albums:SimpleAlbumPage
    init(map: Mapper) throws {
        try tracks = map.from("tracks")
        try artists = map.from("artists")
        try albums = map.from("albums")
    }
}


// MARK: - Extensions
extension FullTrack: Hashable {
    var hashValue: Int {
        return id.hash
    }
    
    static func == (lhs: FullTrack, rhs: FullTrack) -> Bool {
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

