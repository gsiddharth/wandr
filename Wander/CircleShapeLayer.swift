//
//  CircleShapeLayer.swift
//  Wander
//
//  Created by Siddharth Garg on 14/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation
import UIKit

class CircleShapeLayer : CAShapeLayer {
    
    var _elapsedTime : NSTimeInterval! = 0
    var timeLimit : NSTimeInterval!
    var initialProgress : Double!
    var progressLayer : CAShapeLayer!
    
    override init() {
        super.init()
        self.setupLayer()
    }
    
    init(frame : CGRect) {
        super.init()
        super.frame = frame
        self.setupLayer()
    }
    
    override init(layer: AnyObject!){
        super.init()
        self.setupLayer()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        self.setupLayer()
    }
    
    var centerColor : CGColor! {
        get {
            return self.fillColor
        }
        set {
            self.fillColor = newValue
        }
    }
    
    var strokeBackgroundColor : CGColor! {
        get {
            return self.strokeColor
        }
        set {
            self.strokeColor = newValue
        }
    }
    
    var strokeForegroundColor : CGColor! {
        get {
            return self.progressLayer.strokeColor
        }
        set {
            self.progressLayer.strokeColor = newValue
        }
    }
    
    
    override func layoutSublayers() {
       
        //self.path = self.drawPathWithArcCenter()
        //self.progressLayer.path = self.drawPathWithArcCenter()
        super.layoutSublayers()

    }
    
    func setupLayer() {
        self.path = self.drawPathWithArcCenter()
        self.lineWidth = 4
        
        self.progressLayer = CAShapeLayer()
        self.progressLayer.path = self.drawPathWithArcCenter()
        self.progressLayer.lineWidth = 4
        self.progressLayer.lineCap = kCALineCapRound
        self.progressLayer.lineJoin = kCALineJoinRound
        
        self.progressLayer.fillColor = Convertors.convertUIColorToCGColor(UIColor.clearColor())
        self.strokeBackgroundColor = Convertors.convertUIColorToCGColor(UIColor.whiteColor())
        self.strokeForegroundColor = Convertors.convertUIColorToCGColor(UIColor.greenColor())
        
        self.addSublayer(self.progressLayer)
    }
    
    func drawPathWithArcCenter() -> CGPath {

        var position_y : CGFloat = self.frame.size.height/2;
        var position_x : CGFloat = self.frame.size.width/2; // Assuming that width == height
        var retVal : UIBezierPath = UIBezierPath(arcCenter:CGPointMake(position_x, position_y), radius : (position_y * 1.8), startAngle : CGFloat((-M_PI/2)), endAngle : CGFloat((3*M_PI/2)),  clockwise : true)
        return retVal.CGPath
        
    }
    
    var elapsedTime : NSTimeInterval {
        get {
            return self._elapsedTime
        }
        set {
            self.initialProgress = self.calculatePercent(self._elapsedTime, toTime : self.timeLimit)
            self._elapsedTime = newValue;
            self.progressLayer.strokeEnd = CGFloat(self.percent)
            self.startAnimation();
        }
    }
    
    var percent : Double {
        get {
            return self.calculatePercent(self.elapsedTime, toTime : self.timeLimit)
        }
    }
    
    func calculatePercent(fromTime : NSTimeInterval, toTime : NSTimeInterval ) -> Double {
        
        if ((toTime > 0) && (fromTime > 0)) {
            
            var progress : CGFloat = 0;
            
            progress = min(1.0, CGFloat(fromTime / toTime))
            
            return Double(progress);
        }
        else
        {
            return 0.0
        }
    }
    
    func startAnimation() {
        var pathAnimation : CABasicAnimation = CABasicAnimation(keyPath:"strokeEnd")
        pathAnimation.duration = 0.2;
        pathAnimation.fromValue = self.initialProgress;
        pathAnimation.toValue = self.percent
        pathAnimation.removedOnCompletion = true
        self.progressLayer.addAnimation(pathAnimation, forKey:nil)
        
    }
    
    
    
}