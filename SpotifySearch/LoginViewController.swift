//
//  LoginViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/18/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.sessionUpdated),
                                               name: Notification.Name(rawValue: "sessionUpdated"), object: nil)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let auth:SPTAuth = SPTAuth.defaultInstance()
        
        if auth.session == nil {
            print("No session")
            return
        } else if auth.session.isValid() {
            self.performSegue(withIdentifier: "showTabBar", sender: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sessionUpdated(notification:Notification){
        
    }

    func showTabBar(){
        
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
