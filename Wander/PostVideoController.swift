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


class PostVideoController: UIViewController {

    @IBOutlet weak var videoPlayerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if Messages.lastVideoFile != nil {
            var moviePlayer = MPMoviePlayerController(contentURL: Messages.lastVideoFile)
            moviePlayer.view.frame = self.videoPlayerView.bounds
            self.videoPlayerView.addSubview(moviePlayer.view)
            moviePlayer.fullscreen = false
            moviePlayer.controlStyle = MPMovieControlStyle.Embedded
        }

    }
    
}
