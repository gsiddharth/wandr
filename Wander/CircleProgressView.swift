//
//  CircleProgressView.swift
//  Wander
//
//  Created by Siddharth Garg on 14/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation

class CircleProgressView : UIButton {

    var status : String!
    
    var progressLayer : CircleShapeLayer!
    
    var isPressed = false
    
    override init(frame : CGRect) {
        super.init(frame : frame)
        self.setupViews()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        self.setupViews()
    }
    
    var onPressCenterColor : CGColor = Convertors.convertUIColorToCGColor(UIColor.redColor())
    
    var onUnpressCenterColor : CGColor = Convertors.convertUIColorToCGColor(UIColor.grayColor())
    
    var strokeBackgroundColor : CGColor! {
        get {
            return self.progressLayer.strokeBackgroundColor
        }
        
        set {
            self.progressLayer.strokeBackgroundColor = newValue
        }
    }
    
    var strokeForegroundColor : CGColor! {
        get {
            return self.progressLayer.strokeForegroundColor
        }
        
        set {
            self.progressLayer.strokeForegroundColor = newValue
        }

    }

    
    var timeLimit :  NSTimeInterval {
        get {
            return self.progressLayer.timeLimit
        }
        
        set {
            self.progressLayer.timeLimit = newValue
        }
    }

    var elapsedTime : NSTimeInterval! {
        get {
            return self.progressLayer.elapsedTime
        }
        set {
            self.progressLayer.elapsedTime = newValue
        }
    }
    
    var percent : Double! {
        get {
            return self.progressLayer.percent
        }
    }

    override func awakeFromNib() {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    func onButtonPress(sender : AnyObject) {
        if self.isPressed {
            self.progressLayer.centerColor = self.onUnpressCenterColor
        } else {
            self.progressLayer.centerColor = self.onPressCenterColor
        }
        
        isPressed = !isPressed
    }

    func setupViews() {
        self.clipsToBounds = false;
        self.progressLayer = CircleShapeLayer(frame :self.bounds)
        self.progressLayer.centerColor = self.onUnpressCenterColor
        self.layer.addSublayer(self.progressLayer)
        self.addTarget(self, action: "onButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)

    }
}
