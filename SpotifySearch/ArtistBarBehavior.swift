//
//  ArtistBarBehavior.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/9/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import Foundation

class ArtistBarBehavior: BLKFlexibleHeightBarBehaviorDefiner {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if(!self.isCurrentlySnapping){
            let progress = (scrollView.contentOffset.y+scrollView.contentInset.top) /
                            (self.flexibleHeightBar.maximumBarHeight - self.flexibleHeightBar.minimumBarHeight)
            
            self.flexibleHeightBar.progress = progress
            self.flexibleHeightBar.setNeedsLayout()
        }
    }
}
