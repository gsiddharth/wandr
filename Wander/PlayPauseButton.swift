//
//  PlayPauseButton.swift
//  Wander
//
//  Created by Siddharth Garg on 19/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation

class PlayPauseButton : UIButton {
    
    var playing : Bool = false
    
    override init(frame : CGRect) {
        super.init(frame : frame)
        self.setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        self.setupViews()
    }

    func setupViews() {
        self.clipsToBounds = true
        self.addTarget(self, action: "onButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)
        self.setImage(UIImage(named : "play.png"), forState: UIControlState.Normal)
    }

    func onButtonPress(sender : UIButton!) {
        if playing {
            self.setImage(UIImage(named : "pause.png"), forState: UIControlState.Normal)
        } else {
            self.setImage(UIImage(named : "play.png"), forState: UIControlState.Normal)
        }
        
        playing = !playing

    }
    
}