//
//  PlayerViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/21/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PlayerViewController: UIViewController {

    var queue:Variable<[Track]>
    
    var disposeBag:DisposeBag = DisposeBag()
    
    @IBOutlet weak var songProgress: UIProgressView!
    @IBOutlet weak var SongTitle: UILabel!
    @IBAction func PlayPause(_ sender: UIButton) {
    }
    
    
    init(songQueue:Variable<[Track]>) {
        queue = songQueue
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        queue = Variable.init([])
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queue.asObservable().subscribe{ event in
            switch event {
            case .next(_):
                break
                //print("Got Event")
            case .error(_):
                print("Got Error")
            case .completed:
                break
            }
        }.addDisposableTo(disposeBag)
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
