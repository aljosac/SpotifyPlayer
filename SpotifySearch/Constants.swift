//
//  constants.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/18/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import Moya

func secondsToString(seconds:Int) -> String {

    let hours = seconds > 3600 ? "\(seconds / 3600):" : ""
    let minutes = seconds > 60 ? "\(seconds / 60):" : "0:"
    var seconds = "\(seconds % 60)"
    
    if Int(seconds)! < 10 {
        seconds = "0" + seconds
    }
    
    return hours + minutes + seconds
    
}

let requestClosure = { (target: Spotify) -> Endpoint<Spotify> in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(target)
    
    switch target {
    case .TopArtists,.TopArtistTracks,.ArtistAlbums,.Playlist :
        let authToken = "Bearer " + SPTAuth.defaultInstance().session.accessToken
        return defaultEndpoint.adding(newHttpHeaderFields:["Authorization": authToken])
    default:
        return defaultEndpoint
    }
}

class AppState {
    
    static let shared = AppState()
    var playerShowing:Bool = false
    var queueIds:Set<String> = Set()
    let provider = RxMoyaProvider<Spotify>(endpointClosure: requestClosure)
}

let tableGray:UIColor = UIColor(red: 0.147, green: 0.147, blue: 0.147, alpha: 1.0)
let dark:UIColor = UIColor(white: 0.10, alpha: 1.0)
let appGreen:UIColor = UIColor(colorLiteralRed: 0.114, green: 0.725, blue: 0.329, alpha: 1.0)

let albumText = "See All Albums"
let singleText = "See All Singles"
let trackText = "See All Tracks"
let artistText = "See All Artists"
let playlistText = "See All Playlists"

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor,alpha:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.setAlpha(alpha)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
    
    class func combine(images: UIImage...) -> UIImage {
        var contextSize = CGSize.zero
        
        for image in images {
            contextSize.width = max(contextSize.width, image.size.width)
            contextSize.height = max(contextSize.height, image.size.height)
        }
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0)
        
        for image in images {
            let originX = (contextSize.width - image.size.width) / 2
            let originY = (contextSize.height - image.size.height) / 2
            
            image.draw(in: CGRect(x: originX, y:originY, width: image.size.width, height: image.size.height))
        }
        
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return combinedImage!
    }
}

extension BLKDelegateSplitter: UITableViewDelegate {}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
    
    // removes all elements that satisfy eval function and returns them as a list
    mutating func branch(eval:((Element) -> Bool)) -> [Element] {
        var count = self.count
        var loc = 0
        var ret:[Element] = []
        while count-loc > 0 {
            if eval(self[loc]) {
                ret.append(self.remove(at: loc))
                count -= 1
            } else {
                loc += 1
            }
        }
        return ret
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

func calcTop(query:String, items: [SearchItem]) -> SearchItem? {
    var dict:[Int:[SearchItem]] = [:]
    
    for item in items {
        let key = levenshtein(stringOne: item.name, stringTwo: query)!
        var values = dict[key] ?? []
        values.append(item)
        dict[key] = values
    }
    
    // max levenshtein distence is the size of the query
    for i in 0...query.characters.count {
        let values = dict[i] ?? []
        
        if values.count > 0 {
            let max = values.map{$0.popularity}.max()!
            return values.first{$0.popularity == max}!
        }
    }
    return nil
}


