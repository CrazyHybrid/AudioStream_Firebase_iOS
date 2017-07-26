//
//  RecordVC.swift
//  awesomeios
//
//  Created by Andrey on 7/25/17.
//  Copyright © 2017 Leor Benari. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import Firebase

class RecordVC: UIViewController, AVAudioPlayerDelegate{
    
    @IBOutlet weak var readyLabel: UILabel!
    @IBOutlet private var inputPlot: AKNodeOutputPlot!
    @IBOutlet weak var recordbtn: UIButton!
    @IBOutlet weak var uploadbtn: UIButton!
    
    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var player: AKAudioPlayer!
    var tape: AKAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var delay: AKDelay!
    var mainMixer: AKMixer!
    
    let mic = AKMicrophone()
    
    var state = State.readyToRecord
    
    enum State {
        case readyToRecord
        case recording
        case uploading
    }
    
    var tempName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Record"
        
        AKAudioFile.cleanTempDirectory()
        
        // Session settings
        AKSettings.bufferLength = .medium
        
        
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }
        
        AKSettings.defaultToSpeaker = true
        
        // Patching
        inputPlot.node = mic
        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)
        
        // Will set the level of microphone monitoring
        micBooster.gain = 0
        recorder = try? AKNodeRecorder(node: micMixer)
        if let file = recorder.audioFile {
            player = try? AKAudioPlayer(file: file)
        }

        moogLadder = AKMoogLadder(player)
        
        mainMixer = AKMixer(moogLadder, micBooster)
        
        AudioKit.output = mainMixer
        AudioKit.start()

        
        setupUIForRecording ()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
    
    @IBAction func onClickRecord(_ sender: Any) {
        switch state {
        case .readyToRecord :
            
            if player != nil {
                player.stop()
                do {
                    try recorder.reset()
                } catch { print("Errored resetting.") }
            }

            readyLabel.text = "Recording"
            recordbtn.setImage(UIImage(named: "record_stop"), for: UIControlState())
            state = .recording
            // microphone will be monitored while recording
            // only if headphones are plugged
            if AKSettings.headPhonesPlugged {
                micBooster.gain = 1
            }
            do {
                try recorder.record()
            } catch { print("Errored recording.") }
            
        case .recording :
            // Microphone monitoring is muted
            micBooster.gain = 0
            readyLabel.text = "Ready to record"
            do {
                try player.reloadFile()
            } catch { print("Errored reloading.") }
            
            let recordedDuration = player != nil ? player.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                recorder.stop()
                
                let stamp = Date().timeIntervalSince1970
                tempName = String(format: "%.f.m4a", stamp)
                
                print(tempName)
                
                player.audioFile.exportAsynchronously(name: tempName,
                                                      baseDir: .documents,
                                                      exportFormat: .m4a) {_, exportError in
                                                        if let error = exportError {
                                                            print("Export Failed \(error)")
                                                        } else {
                                                            print("Export succeeded")
                                                        }
                }
                setupUIForPlaying ()
            }
        default:
            break;
        }
    }
    
    @IBAction func onClickUploadToServer(_ sender: Any) {
        
//        player.play()
        print(player.audioFile)
        
        let storageRef = FIRStorage.storage().reference().child("audiofiles").child(tempName)
        
        var audioData = Data()
        
        let fileUrl = player.audioFile.url
            
        do {
            audioData = try Data(contentsOf: fileUrl)
        } catch {
            print("Error convert data from url")
        }
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "audio/m4a"
        
        print(audioData)
        
        storageRef.putFile( fileUrl, metadata: metaData, completion: { (metadata, error) in
            
            if let error = error {
                print(error)
                return
            } else {
                let downloadUrl = metadata?.downloadURL()
                let user = FIRAuth.auth()?.currentUser
                print(downloadUrl)
                DBProvider.Instance.saveAudio(withID: (user?.uid)!, url: (downloadUrl?.absoluteString)!, category: "popular")
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
                    
                    let audioPlayer = try AVAudioPlayer(contentsOf: downloadUrl!)
                    
                    audioPlayer.delegate = self
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                    
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        })
    } //https://firebasestorage.googleapis.com/v0/b/awesomestream-532da.appspot.com/o/musicurls%2F1501018910.m4a?alt=media&token=e2d37de7-f14e-47f7-8a69-3ed94b2eb120 downloadUrl	URL?	"https://firebasestorage.googleapis.com/v0/b/awesomestream-532da.appspot.com/o/1501019386.m4a?alt=media&token=1d360d71-e430-4934-b4ba-4f3958e4ef49"	some
    
    func setupUIForRecording () {
        state = .readyToRecord
        readyLabel.text = "Ready to record"
        
        uploadbtn.isEnabled = false
        micBooster.gain = 0
    }
    
    func setupUIForPlaying () {
//        let recordedDuration = player != nil ? player.audioFile.duration  : 0
//        infoLabel.text = "Recorded: \(String(format: "%0.1f", recordedDuration)) seconds"
        
        recordbtn.setImage(UIImage(named: "record"), for: UIControlState())
        
        state = .readyToRecord
        uploadbtn.isEnabled = true
    }
}
