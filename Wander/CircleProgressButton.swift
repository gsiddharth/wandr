//
//  CircleProgressView.swift
//  Wander
//
//  Created by Siddharth Garg on 14/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation

class CircleProgressButton : UIButton {

    private var _pressed = false
    
    var status : String!
    
    var progressLayer : CircleShapeLayer!
    
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
    
    var pressed : Bool {
        get {
            return _pressed
        }
        set {
            _pressed = newValue
            
            if newValue {
                self.progressLayer.centerColor = self.onPressCenterColor
            } else {
                self.progressLayer.centerColor = self.onUnpressCenterColor
            }
        }
    }
    
    func finish() {
        self.pressed = false
        self.enabled = false
        
    }
    
    func reload() {
        self.pressed = false
        self.elapsedTime = 0
    }

    func setupViews() {
        self.progressLayer = CircleShapeLayer(frame :self.bounds)
        self.pressed = false
        self.clipsToBounds = false
        self.layer.addSublayer(self.progressLayer)
    }
}
