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
    case Track(name: String)
    case Album(id: String)
    case Artist(id: String)
}

extension Spotify: TargetType {
    public var baseURL: URL { return URL(string: "https://api.spotify.com")! }
    
    public var path: String {
        switch self {
            
        case .Track(_):
            return "/v1/search"
        case .Artist(let id):
            return "/v1/artists/\(id)/albums"
        case .Album(let id):
            return "/v1/albums/\(id)"
        }
    }
    
    public var method: Moya.Method {
        return .GET
    }
    
    public var parameters:[String:Any]?{
        switch self {
        case .Track(let name):
            return ["query":name+"*","type":"track"]
        default:
            return nil
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .Track(_):
            return "{\"login\": \"\", \"id\": 100}".data(using: String.Encoding.utf8)!
        case .Album(_):
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        case .Artist(_):
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        }
    }
    
    public var task: Task {
        return .request
    }
}
