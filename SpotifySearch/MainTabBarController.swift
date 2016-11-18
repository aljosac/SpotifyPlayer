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

class MainTabBarController: UITabBarController {

    enum Views: Int{
        case queue = 1
        case search = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        let y = self.view.bounds.height - self.tabBar.frame.height - 40
        let width = self.view.bounds.width
        let view:UIView = UIView.init(frame: CGRect(x: CGFloat.init(0), y: y, width: width, height: 40))
        view.backgroundColor = UIColor.black
        view.tag = 1337
        if let window = self.view.window {
            if let rootView = window.rootViewController {
                print("Has Root View")
                rootView.view.addSubview(view)
            }
        } else {
            print("No Window")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
