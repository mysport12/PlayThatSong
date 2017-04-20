//
//  ViewController.swift
//  PlayThatSong
//
//  Created by Craig Martin on 4/10/15.
//  Copyright (c) 2015 MadKitty. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var currentSongLabel: UILabel!
    
    var audioSession: AVAudioSession!
//    var audioPlayer: AVAudioPlayer!
    var audioQueuePlayer: AVQueuePlayer!
    
    var currentSongIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAudioSession()
//        configureAudioPlayer()
        configureAudioQueuePlayer()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleRequest:"), name: "WatchKitDidMakeRequest", object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playButtonPressed(sender: UIButton) {
        self.playMusic()
        self.updateUI()
    }
    
    @IBAction func playPreviousButtonPressed(sender: AnyObject) {
        
        if currentSongIndex > 0 {
            self.audioQueuePlayer.pause()
            self.audioQueuePlayer.seekToTime(kCMTimeZero, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
            let temporarySongIndex = self.currentSongIndex
            let temporaryPlayList = self.createSongs()
        
            self.audioQueuePlayer.removeAllItems()
        
            for var index = temporarySongIndex - 1; index < temporaryPlayList.count; index++ {
                self.audioQueuePlayer.insertItem(temporaryPlayList[index] as! AVPlayerItem, afterItem: nil)
            }
            self.currentSongIndex = temporarySongIndex - 1
            self.audioQueuePlayer.seekToTime(kCMTimeZero, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            self.audioQueuePlayer.play()
            
        }
        self.updateUI()
    }
    
    @IBAction func playNextButtonPressed(sender: AnyObject) {
        self.audioQueuePlayer.advanceToNextItem()
        self.currentSongIndex = self.currentSongIndex + 1
        self.updateUI()
    }
    
    //Audio Functions
    
    func configureAudioSession() {
        self.audioSession = AVAudioSession.sharedInstance()
        
        var categoryError:NSError?
        var activeError:NSError?
        
        self.audioSession.setCategory(AVAudioSessionCategoryPlayback, error: &categoryError)
        println("error \(categoryError)")
        var success = self.audioSession.setActive(true, error: &activeError)
        if !success {
            println("Error making audio session active \(activeError)")
        }
    }
    
//    func configureAudioPlayer() {
//        var songPath = NSBundle.mainBundle().pathForResource("01 Leave the Night On", ofType: "m4a")
//        var songURL = NSURL.fileURLWithPath(songPath!)
//        
//        var songError:NSError?
//        
//        self.audioPlayer = AVAudioPlayer(contentsOfURL: songURL, error: &songError)
//        self.audioPlayer.numberOfLoops = 0
//    }
    
    
    func configureAudioQueuePlayer() {
        
        let songs = createSongs()
        self.audioQueuePlayer = AVQueuePlayer(items: songs)
        
        for var songIndex = 0; songIndex < songs.count; songIndex++ {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "songEnded:", name: AVPlayerItemDidPlayToEndTimeNotification, object: songs[songIndex])
        }
        
    }
    
    func songEnded(notification: NSNotification) {
        self.currentSongIndex = self.currentSongIndex + 1
        self.updateUI()
    }
    
    func playMusic() {

        println("audioQueuePlayer rate \(audioQueuePlayer.rate)")
        println("audioQueuePlayer error \(audioQueuePlayer.error)")
        
        if self.audioQueuePlayer.rate > 0 && self.audioQueuePlayer.error == nil {
            self.audioQueuePlayer.pause()
        } else if currentSongIndex == nil {
            self.audioQueuePlayer.play()
            self.currentSongIndex = 0
        } else {
            self.audioQueuePlayer.play()
        }

    }
    
    func createSongs() -> [AnyObject] {
        
        let firstSongPath = NSBundle.mainBundle().pathForResource("01 Leave the Night On", ofType: "m4a")
        let secondSongPath = NSBundle.mainBundle().pathForResource("03 Where the Boat Leaves From", ofType: "m4a")
        
        let firstSongURL = NSURL.fileURLWithPath(firstSongPath!)
        let secondSongURL = NSURL.fileURLWithPath(secondSongPath!)
        
        let firstItem = AVPlayerItem(URL: firstSongURL)
        let secondItem = AVPlayerItem(URL: secondSongURL)
        
        let songs = [firstItem, secondItem]
        
        return songs
    }
    
    func updateUI() {
        
        self.currentSongLabel.text = currentSongName()
        
        if self.audioQueuePlayer.rate > 0 && self.audioQueuePlayer.error == nil {
            self.playButton.setTitle("Pause", forState: UIControlState.Normal)
        } else {
            self.playButton.setTitle("Play", forState: UIControlState.Normal)
        }
    }
    
    func currentSongName() -> String {
        var currentSong: String!
        
        if self.currentSongIndex == 0 {
            currentSong == "Leave the Night On"
        } else if self.currentSongIndex == 1 {
            currentSong == "Where the Boat Leaves From"
        } else {
            currentSong == "Something went wrong!"
        }
        return currentSong
    }
    
    func handleRequest(notification: NSNotification) {
        
        let watchKitInfo = notification.object as! WatchKitInfo
        
        if watchKitInfo.playerRequest != nil {
            let requestedAction: String = watchKitInfo.playerRequest!
        
            switch requestedAction {
                case "Play":
                    self.playMusic()
                case "Next":
                    self.playNextButtonPressed(self)
                case "Previous":
                    self.playPreviousButtonPressed(self)
                default:
                    println("Default value printed, something went wrong")
            }
            
            let currentSongDictionary = ["Current Song" : currentSongName()]
            watchKitInfo.replyBlock(currentSongDictionary)
        
            self.updateUI()
        }
        
    }
}

