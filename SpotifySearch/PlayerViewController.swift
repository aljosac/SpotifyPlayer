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
import MediaPlayer

class PlayerViewController: UIViewController,SPTAudioStreamingDelegate,SPTAudioStreamingPlaybackDelegate {

    // MARK: - Variables
    var queue:Variable<[FullTrack]>
    var history:Variable<[FullTrack]>
    var currentTrack:FullTrack? = nil
    var disposeBag:DisposeBag = DisposeBag()
    var playing:UIBarButtonItem? = nil
    var isChangingProgress: Bool = false
    var isPlaying:Bool = false
    let audioSession = AVAudioSession.sharedInstance()
    let commandCenter:MPRemoteCommandCenter
    let nowPlayingInfo:MPNowPlayingInfoCenter
    // MARK: - Outlets
    @IBOutlet weak var track: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var album: UIImageView!
    @IBOutlet weak var blurAlbum: UIImageView!
    @IBOutlet weak var trackSlider: UISlider!
    @IBOutlet weak var endSong: UILabel!
    @IBOutlet weak var startSong: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    
    // MARK: - Actions
    @IBAction func playPause(_ sender: UIButton) {
        let state = SPTAudioStreamingController.sharedInstance().playbackState.isPlaying
        SPTAudioStreamingController.sharedInstance().setIsPlaying(!state, callback: nil)
    }
    
    @IBAction func nextSong(_ sender: UIButton) {
        if queue.value.count > 0 {
            SPTAudioStreamingController.sharedInstance().skipNext(nil)
            var mp = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String:Any]()
            mp[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0.0
        }

    }
    
    @IBAction func prevSong(_ sender: UIButton) {
        print(SPTAudioStreamingController.sharedInstance().metadata.prevTrack?.name ?? "SHIT")
        SPTAudioStreamingController.sharedInstance().skipPrevious { _ in
            SPTAudioStreamingController.sharedInstance().setIsPlaying(true, callback: nil)
        }
        
    }
    // touch down
    @IBAction func songSeek(_ sender: UISlider) {
        if SPTAudioStreamingController.sharedInstance().playbackState.isPlaying {
            SPTAudioStreamingController.sharedInstance().setIsPlaying(false, callback: nil)
        }
        self.isChangingProgress = true
        let dest = SPTAudioStreamingController.sharedInstance().metadata!.currentTrack!.duration * Double(sender.value)
        _ = self.songUI(position: dest)
        
    }
    // touch up
    @IBAction func touchSlider(_ sender: UISlider) {
        let dest = SPTAudioStreamingController.sharedInstance().metadata!.currentTrack!.duration * Double(sender.value)
        SPTAudioStreamingController.sharedInstance().seek(to: dest) { error in
            SPTAudioStreamingController.sharedInstance().setIsPlaying(true) { error in
                self.nowPlayingInfo.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = dest
            }
            
        }
    }
    // MARK: - Class Functions
    init(songQueue:Variable<[FullTrack]>?,songHistory:Variable<[FullTrack]>?) {
        print("Player initalized")
        queue = songQueue!
        history = songHistory!
        commandCenter = MPRemoteCommandCenter.shared()
        nowPlayingInfo = MPNowPlayingInfoCenter.default()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        queue = Variable.init([])
        history = Variable.init([])
        commandCenter = MPRemoteCommandCenter.shared()
        nowPlayingInfo = MPNowPlayingInfoCenter.default()
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.track.text = "Nothing Playing"
        self.artist.text = "Really it's nothing"
        //UIApplication.shared.beginReceivingRemoteControlEvents()
        
        self.setupSlider()
        self.newSession()
        self.setupCommand()
    }

    override var prefersStatusBarHidden: Bool { return true }
    
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
    
    func setupCommand() {
        commandCenter.playCommand.addTarget { event in
            SPTAudioStreamingController.sharedInstance().setIsPlaying(true, callback: nil)
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.pauseCommand.addTarget { event in
            SPTAudioStreamingController.sharedInstance().setIsPlaying(false, callback: nil)
            return MPRemoteCommandHandlerStatus.success

        }
        commandCenter.nextTrackCommand.addTarget { event in
            SPTAudioStreamingController.sharedInstance().skipNext(nil)
            return MPRemoteCommandHandlerStatus.success

        }
        
        commandCenter.previousTrackCommand.addTarget { event in
            SPTAudioStreamingController.sharedInstance().skipPrevious(nil)
            return MPRemoteCommandHandlerStatus.success
        }
        
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
                    self.popupItem.image = image
                    let artImage = MPMediaItemArtwork.init(boundsSize: image.size) { (size) in
                        return image
                    }
                    let meta = SPTAudioStreamingController.sharedInstance().metadata.currentTrack!
                    
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle:meta.name,
                                                                       MPMediaItemPropertyArtist:meta.artistName,
                                                                       MPMediaItemPropertyAlbumTitle:meta.albumName,
                                                                       MPMediaItemPropertyPlaybackDuration:meta.duration,
                                                                       MPNowPlayingInfoPropertyElapsedPlaybackTime:0.0,
                                                                       MPMediaItemPropertyArtwork:artImage]
                }
            }
        }
        self.popupItem.title = streamingController?.metadata.currentTrack?.name
        playing = UIBarButtonItem(image: #imageLiteral(resourceName: "pause"), style: .plain, target: self, action: #selector(playPause(_:)))
        self.popupItem.rightBarButtonItems = [playing!]
        self.popupItem.leftBarButtonItems = []
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
    
    func setupSlider() {
        let newThumb = UIImage.circle(diameter: 10, color: .white, alpha:1)
        self.trackSlider.setThumbImage(newThumb, for: .normal)
        let thumbOne = UIImage.circle(diameter: 15, color: .white, alpha: 1)
        let thumbTwo = UIImage.circle(diameter: 25, color: .white, alpha: 0.3)
        let highlightThumb = UIImage.combine(images: thumbOne,thumbTwo)
        self.trackSlider.setThumbImage(highlightThumb, for: .highlighted)
    }
    
    // Updates UI based on current song position
    func songUI(position:TimeInterval) -> Float {
        let positionDouble = Double(position)
        let durationDouble = Double(SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.duration ?? 0)
        let value = Float(positionDouble / durationDouble)
        
        self.startSong.text = secondsToString(seconds: Int(position))
        self.endSong.text = "-" + secondsToString(seconds: Int(durationDouble - position))
        
        self.popupItem.progress = value
        return value
    }
    // MARK: - Audio Streaming Functions
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        let alert = UIAlertController(title: "Message from Spotify", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: { _ in })
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        print("is playing = \(isPlaying)")
        var mp = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String:Any]()
        let dest = (SPTAudioStreamingController.sharedInstance().metadata?.currentTrack?.duration ?? 0.0) * Double(trackSlider.value)
        mp[MPNowPlayingInfoPropertyElapsedPlaybackTime] = dest
        if isPlaying {
            self.playButton.setImage(#imageLiteral(resourceName: "nowPlaying_pause"), for: UIControlState.normal)
            self.playing?.image = #imageLiteral(resourceName: "Pause Filled-32")
            mp[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        } else {
            self.playButton.setImage(#imageLiteral(resourceName: "nowPlaying_play"), for: UIControlState.normal)
            self.playing?.image = #imageLiteral(resourceName: "Play Filled-32")
            mp[MPNowPlayingInfoPropertyPlaybackRate] = 0.0

        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = mp
        isPlaying ? self.activateAudioSession() : self.deactivateAudioSession()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        let value = self.songUI(position: position)
        self.trackSlider.setValue(value, animated: true)
        if value >= 0.995 {
            print("SkipNext")
            audioStreaming.skipNext(nil)
        }
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        self.closeSession()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        print("didReceiveError: \(error!.localizedDescription)")
    }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStartPlayingTrack trackUri: String) {
        self.updateUI()
        nowPlayingInfo.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
    }
    
    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
        if queue.value.count > 0 {
            AppState.shared.queueIds.remove(self.currentTrack!.id)
            self.history.value.append(self.currentTrack!)
            let track = queue.value.removeFirst()
            self.currentTrack = track
            let uri = track.uri
            audioStreaming.playSpotifyURI(uri, startingWith: 0, startingWithPosition: 0) { error in
                
            }
        }
        
    }
    
    func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) {
        print(audioStreaming.metadata.prevTrack?.name ?? "no track")
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("Logged In")
        queue.asObservable().subscribe{ event in
            switch event {
            case .next(_):
                if self.queue.value.count >= 1 && !self.isPlaying {
                    
                    self.isPlaying = true
                    let track:FullTrack = self.queue.value.removeFirst()
                    self.currentTrack = track
                    print("Removed First")
                    let controller = SPTAudioStreamingController.sharedInstance()
                    controller?.playSpotifyURI(track.uri, startingWith: 0, startingWithPosition: 0){ response in
                        
                        if let error = response {
                            
                            print("*** failed to play: " + error.localizedDescription)
                            return
                        }
                        self.isPlaying = true
                    }
                }
            case .error(_):
                print("Got Error")
            case .completed:
                break
            }
            }.addDisposableTo(disposeBag)
        
    }
    
}

