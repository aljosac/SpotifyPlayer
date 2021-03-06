//
//  TrackEntity.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/3/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Mapper



class SimpleTrack: Mappable {
    
    let name: String
    let id:String
    let artists:[SimpleArtist]
    required init(map: Mapper) throws {
        try name = map.from("name")
        try id = map.from("id")
        try artists = map.from("artists")
    }
}

class FullTrack: SimpleTrack {
    
    let popularity: Int
    let album:SimpleAlbum
    let uri:String
    required init(map: Mapper) throws {
        try popularity = map.from("popularity")
        try album = map.from("album")
        try uri = map.from("uri")
        try super.init(map: map)
    }
}

class SimpleArtist: Mappable {
    
    let name:String
    let id:String
    
    required init(map: Mapper) throws {
        try name = map.from("name")
        try id = map.from("id")
        
    }
}

class FullArtist: SimpleArtist {
    
    var images:[Image]
    let popularity:Int

    required init(map: Mapper) throws {
        try images = map.from("images")
        try popularity = map.from("popularity")
        try super.init(map: map)
    }
}

class SimpleAlbum: Mappable {
    let name:String
    let type:String
    let id:String
    var images:[Image]
    let artists:[SimpleArtist]
    required init(map: Mapper) throws {
        try name = map.from("name")
        try type = map.from("album_type")
        try images = map.from("images")
        try id = map.from("id")
        try artists = map.from("artists")
    }
}

class FullAlbum: SimpleAlbum {
    let tracks:SimpleTrackPage
    required init(map: Mapper) throws {
        try tracks = map.from("tracks")
        try super.init(map: map)
    }
}

class SimplePlaylist: Mappable {
    let name:String
    var images:[Image]
    let type:String
    let pid:String
    let uid:String
    required init(map:Mapper) throws {
        try name = map.from("name")
        try pid = map.from("id")
        try type = map.from("type")
        try images = map.from("images")
        try uid = map.from("owner.id")
    }
}

class FullPlaylist: SimplePlaylist {
    let tracks:FullPlaylistPage
    required init(map:Mapper) throws {
        try tracks = map.from("tracks")
        try super.init(map: map)
    }
}

struct Image: Mappable {
    let url:String
    var image:UIImage?
    init(map: Mapper) throws {
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
    var next:String?
    let total:Int
    let limit:Int
    var offset:Int
    required init(map: Mapper) throws {
        next = map.optionalFrom("next")
        try total = map.from("total")
        try limit = map.from("limit")
        try offset = map.from("offset")
    }
    
}

class SimpleTrackPage: Page {
    
    var items:[SimpleTrack]
    
    required init(map: Mapper) throws {
        try items = map.from("items")
        try super.init(map: map)
    }
}

class FullTrackPage: Page {
    
    var items:[FullTrack]
    
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

class FullArtistPage: Page {
    
    var items:[FullArtist]
    
    required init(map: Mapper) throws {
        try items = map.from("items")
        try super.init(map: map)
    }
}

class SimplePlaylistPage: Page {
    
    var items:[SimplePlaylist]
    
    required init(map: Mapper) throws {
        try items = map.from("items")
        try super.init(map: map)
    }
}

class FullPlaylistPage: Page {
    
    var items:[PlaylistTrack]
    
    required init(map: Mapper) throws {
        try items = map.from("items")
        try super.init(map: map)
    }
}

class PlaylistTrack:Mappable {
    let track:FullTrack
    
    required init(map:Mapper) throws {
        track = try map.from("track")
    }
}


struct Result:Mappable {
    
    let tracks:FullTrackPage
    let artists:FullArtistPage
    let albums:SimpleAlbumPage
    let playlist:SimplePlaylistPage
    init(map: Mapper) throws {
        try tracks = map.from("tracks")
        try artists = map.from("artists")
        try albums = map.from("albums")
        try playlist = map.from("playlists")
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

extension SimplePlaylist:Hashable {
    
    var hashValue: Int {
        return name.hash
    }
    
    static func == (lhs: SimplePlaylist, rhs: SimplePlaylist) -> Bool {
        return lhs.pid == rhs.pid
    }
}

