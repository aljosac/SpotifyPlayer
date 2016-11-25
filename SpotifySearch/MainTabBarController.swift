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

    var queueViewController:QueueTableViewController? {
        return (self.viewControllers?[0] as? UINavigationController)?.topViewController as? QueueTableViewController
    }
    
    var searchViewController:SearchViewController? {
        return (self.viewControllers?[1] as? UINavigationController)?.topViewController as? SearchViewController
    }
    
    var playerController:PlayerViewController? = nil
    
    override func viewDidLoad() {
        print("View loading tab bar")
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        let queue = queueViewController?.queue
        playerController = PlayerViewController(songQueue: queue)
        self.presentPopupBar(withContentViewController: playerController!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if let playerView = playerController?.view {
            if !playerView.isHidden {
                let h = CGFloat(viewController.view.frame.height - self.tabBar.frame.height)
                viewController.view.frame = CGRect(x:CGFloat(0), y:CGFloat(0), width:self.view.bounds.width, height:h)
            }
        }
        
    }
    

}
