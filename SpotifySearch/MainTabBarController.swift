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
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        let y = self.view.bounds.height - (self.tabBar.frame.height * 2)
        let width = self.view.bounds.width
        let queue = queueViewController!.queue
        playerController = PlayerViewController(songQueue: queue)
        if let player = playerController {
            player.view.frame = CGRect(x: CGFloat.init(0), y: y, width: width, height: self.tabBar.frame.height)
            self.view.addSubview(player.view)
        }
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
