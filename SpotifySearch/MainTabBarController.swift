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

    var queueArray:Variable<[Track]> = Variable.init([])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
