//
//  PostVideoController.swift
//  Wander
//
//  Created by Siddharth Garg on 19/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import QuartzCore
import MediaPlayer
import Player
import SwiftHTTP


class ReviewVideoController: UIViewController, PlayerDelegate, VideoMessageProcessorDelegate {

    var player : Player!
    
    @IBOutlet weak var videoPlayerView: UIView!
    
    @IBOutlet weak var playPauseButton: PlayPauseButton! {
        didSet{
            playPauseButton.playing = true
        }
    }
    
    var videoFile : NSURL!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if self.videoFile != nil {
            self.navigationController!.navigationBar.translucent = false;
            self.player = Player()
            self.player.view.frame = self.videoPlayerView.bounds
        
            self.addChildViewController(self.player)
            self.videoPlayerView.clipsToBounds = true
            self.videoPlayerView.addSubview(self.player.view)
            self.player.didMoveToParentViewController(self)
            self.player.fillMode = AVLayerVideoGravityResizeAspectFill
            self.player.delegate = self
            self.player.path = self.videoFile.description
            self.player.playFromBeginning()
        }
    }
    
    func setVideoFilePath(path : String) {
        videoFile = NSURL(fileURLWithPath: path)!
    }
    
    @IBAction func onPlayPauseButtonClick(sender: PlayPauseButton) {
        if playPauseButton.playing {
            if player.playbackState == PlaybackState.Paused {
                self.player.playFromCurrentTime()
            } else if player.playbackState == PlaybackState.Stopped {
                self.player.playFromBeginning()
            }
        } else {
            self.player.pause()
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "reviewToPostSegue" {
            loadPostVideoController()
            return false
        }
        
        return false
    }

    func loadPostVideoController(){
        
        var postVideoController : PostVideoController = self.storyboard?.instantiateViewControllerWithIdentifier("postVideoController") as! PostVideoController
        
        postVideoController.setVideoFilePath(videoFile.path!)
        
        var navigationController : UINavigationController = UINavigationController(rootViewController: postVideoController)
        
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }

    func playerBufferingStateDidChange(player: Player) {
        if player.playbackState == PlaybackState.Paused || player.playbackState == PlaybackState.Stopped  {
            playPauseButton.playing = false
        } else if player.playbackState == PlaybackState.Playing {
            playPauseButton.playing = true
        }
    }
    
    func playerPlaybackDidEnd(player: Player) {
        if player.playbackState == PlaybackState.Paused || player.playbackState == PlaybackState.Stopped  {
            playPauseButton.playing = false
        } else if player.playbackState == PlaybackState.Playing {
            playPauseButton.playing = true
        }
    }
    
    
    func playerReady(player: Player){}
    
    func playerPlaybackStateDidChange(player: Player) {}
    
    func playerPlaybackWillStartFromBeginning(player: Player) {}
    
}
