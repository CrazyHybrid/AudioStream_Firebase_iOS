//
//  preVideoVC.swift
//  awesomeios
//
//  Created by Andrey on 7/24/17.
//  Copyright © 2017 Leor Benari. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation


class preVideoViewController : UIViewController {
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareVideoBackground()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        avPlayer.play()
        paused = false

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
        avPlayer.pause()
        paused = true

    }
    
    func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "signInVC")
        
        self.navigationController?.pushViewController(nextViewController, animated: true)

    }
    
}


extension preVideoViewController{
    
    fileprivate func prepareVideoBackground() {
        guard let videoPath = Bundle.main.path(forResource: "intro", ofType:"mp4") else {
            debugPrint("intro.mp4 not found")
            return
        }
        avPlayer = AVPlayer(url: URL(fileURLWithPath: videoPath))
        avPlayer.actionAtItemEnd = .none
        avPlayer.isMuted = true
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
    }
    
}
