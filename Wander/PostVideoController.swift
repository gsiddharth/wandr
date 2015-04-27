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


class PostVideoController: UIViewController, PlayerDelegate {

    @IBOutlet weak var videoPlayerView: UIView!
    
    @IBOutlet weak var playPauseButton: PlayPauseButton! {
        didSet{
            playPauseButton.playing = true
        }
    }
    var player : Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Messages.lastVideoFile != nil {
            self.player = Player()
            self.player.view.frame = self.videoPlayerView.bounds
           
            player.view.center = CGPointMake(CGRectGetMidX(self.videoPlayerView.bounds), CGRectGetMidY(self.videoPlayerView.bounds) + self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height)
            
            self.addChildViewController(self.player)
            self.videoPlayerView.clipsToBounds = true
            self.videoPlayerView.addSubview(self.player.view)
            self.player.didMoveToParentViewController(self)
            self.player.fillMode = AVLayerVideoGravityResizeAspectFill
            self.player.delegate = self
            self.player.path = Messages.lastVideoFile.description
            self.player.playFromBeginning()
        }
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
    
    func playerReady(player: Player){
        
    }
    
    func playerPlaybackStateDidChange(player: Player) {
        
    }
    
    func playerBufferingStateDidChange(player: Player) {
        if player.playbackState == PlaybackState.Paused || player.playbackState == PlaybackState.Stopped  {
            playPauseButton.playing = false
        } else if player.playbackState == PlaybackState.Playing {
            playPauseButton.playing = true
        }
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
        
    }
    
    func playerPlaybackDidEnd(player: Player) {
        if player.playbackState == PlaybackState.Paused || player.playbackState == PlaybackState.Stopped  {
            playPauseButton.playing = false
        } else if player.playbackState == PlaybackState.Playing {
            playPauseButton.playing = true
        }
    }
}
