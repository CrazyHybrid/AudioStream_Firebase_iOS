//
//  MusicListVC.swift
//  awesomeios
//
//  Created by Andrey on 7/25/17.
//  Copyright © 2017 Leor Benari. All rights reserved.
//

import Foundation
import UIKit
import Jukebox
import SlideMenuControllerSwift


class MusicListViewCell : UITableViewCell {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var category: UILabel!
    
    @IBOutlet weak var morebtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class MusicListVC : UIViewController {
    
    @IBOutlet weak var playbtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selLogo: UIImageView!
    @IBOutlet weak var selName: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var durationTime: UILabel!
    
    @IBOutlet weak var seekBar: UISlider!

    
    var jukebox : Jukebox!
    var musicList = [[String: Any]]()
    
    let imageList = ["img-1.png", "img-2.png", "img-3.png", "img-4.png", "img-5.png", "img-10.png","img-11.png", "img-12.png", "img-13.png", "img-14.png"]
    let usernameList = ["Smith jon", "Willey Steve", "Doe Jhon", "Michael Jackson", "Miley Cyrus", "Smith jon", "Doe Jhon", "Justin Bieber", "Willey Steve", "Michael Jackson"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Recent"
        
        configureUI()
        
        // begin receiving remote events
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
//        if jukebox.currentItem == nil {
//            jukebox = Jukebox(delegate: self, items: [
//                JukeboxItem(URL: URL(string: "https://firebasestorage.googleapis.com/v0/b/awesomestream-532da.appspot.com/o/sample.m4a?alt=media&token=3c08a654-dbd7-417b-8093-ea32b6646246")!)
//                ])!
//            
//        }
//        // configure jukebox
//        jukebox = Jukebox(delegate: self, items: [
//            JukeboxItem(URL: URL(string: "https://firebasestorage.googleapis.com/v0/b/awesomestream-532da.appspot.com/o/sample.m4a?alt=media&token=3c08a654-dbd7-417b-8093-ea32b6646246")!)
//            ])!

        
        
        
//        /// Later add another item
//        let delay = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: delay) {
//            self.jukebox.append(item: JukeboxItem (URL: URL(string: "http://www.noiseaddicts.com/samples_1w72b820/2228.mp3")!), loadingAssets: true)
//        }

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func progressSliderValueChanged(_ sender: Any) {
        
        if jukebox == nil {
            return
        }

        
        if let duration = jukebox.currentItem?.meta.duration {
            jukebox.seek(toSecond: Int(Double(seekBar.value) * duration))
        }
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if jukebox == nil {
            return
        }
        switch jukebox.state {
        case .ready :
            jukebox.play(atIndex: 0)
            playbtn.setImage(UIImage(named: "play"), for: UIControlState())
        case .playing :
            jukebox.pause()
            playbtn.setImage(UIImage(named: "play"), for: UIControlState())
        case .paused :
            playbtn.setImage(UIImage(named: "pause"), for: UIControlState())
            jukebox.play()
        default:
            jukebox.stop()
        }
        
    }
    
    func populateLabelWithTime(_ label : UILabel, time: Double) {
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        
        label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    
    func resetUI()
    {
        durationTime.text = "00:00"
        currentTime.text = "00:00"
        seekBar.value = 0
    }
    
    func configureUI ()
    {
        resetUI()
        
        let color = UIColor(red:0.84, green:0.09, blue:0.1, alpha:1)

        indicator.color = color
        seekBar.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())
        seekBar.minimumTrackTintColor = color
        seekBar.maximumTrackTintColor = UIColor.black

        if jukebox == nil {
            playbtn.setImage(UIImage(named: "play_disable"), for: UIControlState())
        } else {
            playbtn.setImage(UIImage(named: "play"), for: UIControlState())
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

extension MusicListVC : JukeboxDelegate {
    
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        print("Jukebox did load: \(item.URL.lastPathComponent)")
    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        
        if let current = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
            let value = Float(current / duration)
            seekBar.value = value
            populateLabelWithTime(currentTime, time: current)
            populateLabelWithTime(durationTime, time: duration)
        } else {
            resetUI()
        }
    }
    
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            self.indicator.alpha = jukebox.state == .loading ? 1 : 0
            self.playbtn.alpha = jukebox.state == .loading ? 0 : 1
            self.playbtn.isEnabled = jukebox.state == .loading ? false : true
        })
        
        if jukebox.state == .ready {
            playbtn.setImage(UIImage(named: "play"), for: UIControlState())
        } else if jukebox.state == .loading  {
            playbtn.setImage(UIImage(named: "pause"), for: UIControlState())
        } else {
            
            let imageName: String
            switch jukebox.state {
            case .playing, .loading:
                imageName = "pause"
            case .paused, .failed, .ready:
                imageName = "play"
            }
            playbtn.setImage(UIImage(named: imageName), for: UIControlState())
        }
        
        print("Jukebox state changed to \(jukebox.state)")
    }
    
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        print("Item updated:\n\(forItem)")
    }
    
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type == .remoteControl {
            switch event!.subtype {
            case .remoteControlPlay :
                jukebox.play()
            case .remoteControlPause :
                jukebox.pause()
            case .remoteControlNextTrack :
                jukebox.playNext()
            case .remoteControlPreviousTrack:
                jukebox.playPrevious()
            case .remoteControlTogglePlayPause:
                if jukebox.state == .playing {
                    jukebox.pause()
                } else {
                    jukebox.play()
                }
            default:
                break
            }
        }
    }
    
    func onLike(_ sender: Any){
        
    }
    
    func onComment(_ sender: Any){
        
    }
    
    func onShare(_ sender: Any){
        
    }
    
    func OnClickMore( sender: UIButton) {
        
        let menuArray = [KxMenuItem.init(" like ", image: UIImage(named:"like"), target: self, action: #selector(MusicListVC.onLike(_:))),
                         KxMenuItem.init(" comment ", image: UIImage(named:"comment"), target: self, action: #selector(MusicListVC.onComment(_:))),
                         KxMenuItem.init(" share ", image: UIImage(named:"share"), target: self, action: #selector(MusicListVC.onShare(_:)))]
        
        
        KxMenu.setTitleFont(UIFont(name: "HelveticaNeue", size: 17))
        
        //config
        let options = OptionalConfiguration(arrowSize: 0,  //Indicates the arrow size
            marginXSpacing: 7,
            marginYSpacing: 7,
            intervalSpacing: 25,
            menuCornerRadius: 6,
            maskToBackground: true,
            shadowOfMenu: false,
            hasSeperatorLine: true,
            seperatorLineHasInsets: false,
            textColor: Colour(R: 0, G: 0, B: 0),
            menuBackgroundColor: Colour(R: 1, G: 1, B: 1)
        )
        
        let frame = sender.superview?.convert(sender.frame, to: self.view)
        
        KxMenu.show(in: self.view, from: frame!, menuItems: menuArray, withOptions: options)
        
    }

}

extension MusicListVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicListViewCell", for: indexPath) as! MusicListViewCell
        
        cell.logo.image = UIImage(named: imageList[indexPath.row])
        cell.name.text = usernameList[indexPath.row]
        cell.morebtn.addTarget(self, action: #selector(OnClickMore(sender:)), for: .touchUpInside)
        
        return cell
    }
}

extension MusicListVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if jukebox != nil {
            jukebox.stop()
            resetUI()
        }
        
        jukebox = Jukebox(delegate: self, items: [
                        JukeboxItem(URL: URL(string: "https://firebasestorage.googleapis.com/v0/b/awesomestream-532da.appspot.com/o/audiofiles%2Fsample.m4a?alt=media&token=437ecfb6-1bbf-462a-b9aa-ad0053b954f8")!)
            
                        ])!
        
        if jukebox != nil {
            playbtn.setImage(UIImage(named: "play"), for: UIControlState())
            selLogo.image = UIImage(named: imageList[indexPath.row])
            selName.text = usernameList[indexPath.row]
            
        }
    }
}

extension MusicListVC : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}
