//
//  PlayerViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/21/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import AVFoundation
import RxCocoa
import RxSwift
import Alamofire

class PlayerViewController: UIViewController,SPTAudioStreamingDelegate,SPTAudioStreamingPlaybackDelegate {

    // MARK: - Variables
    var queue:Variable<[Track]>
    var currentTrack:Track? = nil
    var disposeBag:DisposeBag = DisposeBag()
    let audioSession = AVAudioSession.sharedInstance()
    
    @IBOutlet weak var track: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var album: UIImageView!
    @IBOutlet weak var blurAlbum: UIImageView!
    @IBOutlet weak var trackSlider: UISlider!
       
    @IBAction func playPause(_ sender: UIButton) {
        let state = SPTAudioStreamingController.sharedInstance().playbackState.isPlaying
        if state {
            sender.setImage(#imageLiteral(resourceName: "nowPlaying_pause"), for: UIControlState.normal)
    
        } else {
            sender.setImage(#imageLiteral(resourceName: "nowPlaying_play"), for: UIControlState.normal)
        }
        SPTAudioStreamingController.sharedInstance().setIsPlaying(!state, callback: nil)
    }
    @IBAction func nextSong(_ sender: UIButton) {
        
    }
    @IBAction func prevSong(_ sender: UIButton) {
        SPTAudioStreamingController.sharedInstance().skipPrevious(nil)
        SPTAudioStreamingController.sharedInstance().setIsPlaying(true, callback: nil)
    }
    // MARK: - Class Functions
    init(songQueue:Variable<[Track]>?) {
        print("Player initalized")
        queue = songQueue!
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        queue = Variable.init([])
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.track.text = "Nothing Playing"
        self.artist.text = "Really it's nothing"
        self.newSession()
        queue.asObservable().subscribe{ event in
            switch event {
            case .next(_):
                if self.queue.value.count > 0 {
                    
                    let track:Track = self.queue.value.removeFirst()
                    print("Removed First")
                    let controller = SPTAudioStreamingController.sharedInstance()
                    self.updateUI()
                    controller?.playSpotifyURI(track.uri, startingWith: 0, startingWithPosition: 0){ response in
                        if let error = response {
                            print("*** failed to play: " + error.localizedDescription)
                            return
                        }
                    }
                }
            case .error(_):
                print("Got Error")
            case .completed:
                break
            }
            }.addDisposableTo(disposeBag)
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View Appeared")
        //self.newSession()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User defined funcions
    func newSession() {
        do {
            let audioController:SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
            let cid = SPTAuth.defaultInstance().clientID
            try audioController.start(withClientId: cid, audioController: nil, allowCaching: true)
            audioController.delegate = self
            audioController.playbackDelegate = self
            audioController.diskCache = SPTDiskCache()
            audioController.login(withAccessToken: SPTAuth.defaultInstance().session.accessToken)
        } catch let error {
            let alert = UIAlertController(title: "Player start Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.closeSession()
        }
        print("Session Created")
    }
    
    func closeSession(){
        do {
            try SPTAudioStreamingController.sharedInstance().stop()
            self.removeFromParentViewController()
        } catch let error {
            let alert = UIAlertController(title: "Player stop Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        print("Session Closed")
    }
    
    func updateUI(){
        
        if SPTAudioStreamingController.sharedInstance().metadata == nil || SPTAudioStreamingController.sharedInstance().metadata.currentTrack == nil {
            return
        }
        
        let streamingController = SPTAudioStreamingController.sharedInstance()
        self.track.text = streamingController?.metadata.currentTrack?.name
        self.artist.text = streamingController?.metadata.currentTrack?.artistName
        if let url = streamingController?.metadata.currentTrack?.albumCoverArtURL {
            Alamofire.request(url).responseData { response in
                if let data = response.data {
                    let image:UIImage = UIImage(data: data)!
                    self.album.image = image
                    self.blurAlbum.image = image
                }
            }
        }
        
        print("UI Updated")
    }
    
    func activateAudioSession() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        }
        catch let error {
            print(error.localizedDescription)
        }
        print("Audio Activated")
    }
    
    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        }
        catch let error {
            print(error.localizedDescription)
        }
        print("Audio Deactivated ")
    }
    // MARK: - Audio Streaming Functions
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        let alert = UIAlertController(title: "Message from Spotify", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: { _ in })
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        print("is playing = \(isPlaying)")
        isPlaying ? self.activateAudioSession() : self.deactivateAudioSession()
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        print("updateUI Called")
        self.updateUI()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        let positionDouble = Double(position)
        let durationDouble = Double(SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.duration)
        self.trackSlider.setValue(Float(positionDouble / durationDouble), animated: true)
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        self.closeSession()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        print("didReceiveError: \(error!.localizedDescription)")
    }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStartPlayingTrack trackUri: String) {
        print("Starting \(trackUri)")
        print("Source \(SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.playbackSourceUri)")
        // If context is a single track and the uri of the actual track being played is different
        // than we can assume that relink has happended.
        let isRelinked = SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.playbackSourceUri.contains("spotify:track") && !(SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.playbackSourceUri == trackUri)
        print("Relinked \(isRelinked)")
    }
}
