//
//  SpotifySearchModel.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 9/20/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation
import Moya
import RxSwift

struct SpotifySearchModel {
    let provider: RxMoyaProvider<Spotify>
    
    internal func searchTrack(query: String) -> Observable<SPTTrack> {
        
        let json = self.provider
        .request(Spotify.Track(name: query))

        
        return Observable.just(SPTTrack())
    }
    
    internal func searchAlbum(query: String) -> Observable<SPTAlbum> {
        return Observable.just(SPTAlbum())
    }
    
    internal func searchArtist(query: String) -> Observable<SPTArtist> {
        return Observable.just(SPTArtist())
    }
}
