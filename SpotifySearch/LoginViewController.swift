//
//  LoginViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/18/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, WebViewControllerDelegate {

    var authViewController: UIViewController?
    
    @IBAction func loginTapped(_ sender: UIButton) {
        let auth:SPTAuth = SPTAuth.defaultInstance()
    
        if SPTAuth.spotifyApplicationIsInstalled() && SPTAuth.supportsApplicationAuthentication() {
            let url = auth.spotifyAppAuthenticationURL()!
            UIApplication.shared.open(url, options: [:],completionHandler: nil)
            
        } else {
            // Opens a web auth view to get a spotify session
            let url:URL = auth.spotifyWebAuthenticationURL()
            self.authViewController = self.getAuthViewController(withURL: url)
            
            self.definesPresentationContext = true
            self.present(self.authViewController!, animated: true, completion: nil)
        }
    }
    
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.sessionUpdated),
                                               name: Notification.Name(rawValue: "SessionUpdated"), object: nil)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let auth:SPTAuth = SPTAuth.defaultInstance()
        
        // Check if there is a cashed session
        if let data = UserDefaults.standard.value(forKey: "SpotifySession") as? Data {
            let session = NSKeyedUnarchiver.unarchiveObject(with: data) as? SPTSession
            auth.session = session!
        }
        
        if auth.session == nil {
            print("No session")
            return
        } else if auth.session.isValid() {
            OperationQueue.main.addOperation {
                [weak self] in
                self?.performSegue(withIdentifier: "showTabBar", sender: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sessionUpdated(notification:Notification){
        let auth:SPTAuth = SPTAuth.defaultInstance()
        self.presentedViewController?.dismiss(animated: true) {
            if auth.session != nil && auth.session.isValid() {
                
                OperationQueue.main.addOperation {
                    [weak self] in
                    self?.performSegue(withIdentifier: "showTabBar", sender: nil)
                }
                
            } else {
                print("Session not found")
            }
        }
    }

    func getAuthViewController(withURL url: URL) -> UIViewController {
        let webView = WebViewController(url: url)
        webView.delegate = self
        
        return webView
    }
    
    func webViewControllerDidFinish(_ controller: WebViewController) {
        // User tapped the close button. Treat as auth error
    }
    

}
