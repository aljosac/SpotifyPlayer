//
//  SpotifyEndpoint.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 9/19/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import Moya
import Moya_ModelMapper


private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)!
    }
}

let SpotifyProvider = RxMoyaProvider<Spotify>()

public enum Spotify {
    case Search(name: String)
    case Album(id: String)
    case Artist(id: String)
    case TopArtists
    case TopArtistTracks(id:String)
    case ArtistAlbums(id:String)
    case Artists(id: String)
    case Track(id: String)
    case Tracks(id: String)
}

extension Spotify: TargetType {
    public var baseURL: URL { return URL(string: "https://api.spotify.com")! }
    
    public var path: String {
        switch self {
            
        case .Search(_):
            return "/v1/search"
        case .Artist(let id):
            return "/v1/artists/\(id)"
        case .Album(let id):
            return "/v1/albums/\(id)"
        case .TopArtists:
            return "/v1/me/top/artists"
        case .TopArtistTracks(let id):
            return "/v1/artists/\(id)/top-tracks"
        case .ArtistAlbums(let id):
            return "/v1/artists/\(id)/albums"
        case .Artists(id:_):
            return "/v1/artists"
        case .Track(let id):
            return "/v1/tracks/\(id)"
        case .Tracks(id:_):
            return "/v1/tracks"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var parameters:[String:Any]?{
        switch self {
        case .Search(let name):
            return ["query":name+"*","type":"track,artist,album"]
        case .ArtistAlbums(_):
            return ["album_type":"album,single","market":"US","limit":"50"]
        case .TopArtistTracks(id: _):
            return ["country":"US"]
        case .Artists(let id), .Tracks(let id):
            return ["ids":id]
        default:
            return nil
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .Search(_):
            return "{\"login\": \"\", \"id\": 100}".data(using: String.Encoding.utf8)!
        case .Album(_):
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        case .Artist(_):
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        case .TopArtists:
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        default:
            return "".data(using: String.Encoding.utf8)!
        }
    }
    
    public var task: Task {
        return .request
    }
}
