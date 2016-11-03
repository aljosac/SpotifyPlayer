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
    case Album(name: String)
    case Artist(name: String)
}

extension Spotify: TargetType {
    public var baseURL: URL { return URL(string: "https://api.spotify.com")! }
    
    public var path: String {
        switch self {
            
        case .Track(let name):
            return "/v1/search?query=\(name.URLEscapedString)*&type=track"
        case .Artist(let name):
            return "/v1/search?query=\(name.URLEscapedString)*&type=artist"
        case .Album(let name):
            return "/v1/search?query=\(name.URLEscapedString)*&type=album"
        }
    }
    
    public var method: Moya.Method {
        return .GET
    }
    
    public var parameters:[String:Any]?{
        return nil
    }
    
    public var sampleData: Data {
        switch self {
        case .Track(_):
            return "{\"login\": \"\", \"id\": 100}".data(using: String.Encoding.utf8)!
        case .Album(_):
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        case .Artist(name: _):
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        }
    }
    
    public var task: Task {
        return .request
    }
}
