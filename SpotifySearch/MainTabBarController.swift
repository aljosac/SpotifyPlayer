//
//  ViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/11/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class MainTabBarController: UITabBarController,UITabBarControllerDelegate {

    var queueViewController:QueueTableViewController {
        return (self.viewControllers?[0] as? UINavigationController)?.topViewController as! QueueTableViewController
    }
    
    var searchViewController:SearchViewController {
        return (self.viewControllers?[1] as? UINavigationController)?.topViewController as! SearchViewController
    }
    
    var state = AppState.shared
    var playerController:PlayerViewController? = nil
    
    override func viewDidLoad() {
        print("View loading tab bar")
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.tintColor = appGreen
        self.tabBar.barStyle = .black
        self.tabBar.barTintColor = UIColor(white: 0.10, alpha: 1.0)
        self.tabBar.isTranslucent = false
        
    }

    override func viewDidAppear(_ animated: Bool) {
        // create and configure popup player
        let queue = queueViewController.queue
        let history = queueViewController.history
        playerController = PlayerViewController(songQueue: queue,songHistory:history)
    }
    
    func presentPlayer() {
        if !AppState.shared.playerShowing {
            self.presentPopupBar(withContentViewController: playerController!, animated: true, completion: nil)
//            self.popupBar?.titleTextAttributes = ["NSFontAttributeName":UIFont.boldSystemFont(ofSize: 20)]
            state.playerShowing = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        
    }
    

}
