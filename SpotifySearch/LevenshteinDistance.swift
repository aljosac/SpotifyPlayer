//
//  LevenshteinDistance.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/29/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation

// Levenshtein distance of partial strings - 0 is a perfect match
func levenshtein(stringOne:String,stringTwo:String) -> Int? {
    let size = min(stringOne.characters.count, stringTwo.characters.count)
    var d:[[Int]] = []
    if size == 0 {
        return nil
    }
    // init matrix
    for row in 0...size {
        if row == 0 {
            // set first row
            d.append(Array.init(0...size))
        } else {
            // Construct row
            var r = [row]
            let end = [Int].init(repeating: 0, count: size)
            r.append(contentsOf: end)
            
            d.append(r)
        }
    }
    
    // Calculate
    for i in 1...size {
        for j in 1...size {
            let idx1 = stringOne.index(stringOne.startIndex, offsetBy: i-1)
            let idx2 = stringTwo.index(stringTwo.startIndex, offsetBy: i-1)
            let cost = stringOne[idx1] == stringTwo[idx2] ? 0 : 1
            
            d[i][j] = min(d[i-1][j]+1,d[i-1][j-1]+cost,d[i][j-1]+1)
        }
    }
    
    return d[size][size]
}
