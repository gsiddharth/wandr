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
    
    var elapsedTime : NSTimeInterval!
    var timeLimit : NSTimeInterval!
    var _percent : Double!
    var initialProgress : Double!
    var progressLayer : CAShapeLayer!
    
    override init() {
        super.init()
        self.setupLayer()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
    }
    
    override func layoutSublayers() {
        self.path = self.drawPathWithArcCenter()
        self.progressLayer.path = self.drawPathWithArcCenter()
        super.layoutSublayers()

    }
    
    func setupLayer() {
        self.path = self.drawPathWithArcCenter()
        self.fillColor = UIColor.clearColor().CGColor
        self.strokeColor = UIColor(red :0.86, green:0.86, blue:0.86, alpha:0.4).CGColor
        self.lineWidth = 20;
        
        self.progressLayer = CAShapeLayer()
        self.progressLayer.path = self.drawPathWithArcCenter()
        self.progressLayer.fillColor = UIColor.clearColor().CGColor
        self.progressLayer.strokeColor = UIColor.whiteColor().CGColor
        self.progressLayer.lineWidth = 20;
        self.progressLayer.lineCap = kCALineCapRound;
        self.progressLayer.lineJoin = kCALineJoinRound;
        self.addSublayer(self.progressLayer)
    }
    
    func drawPathWithArcCenter() -> CGPath {

        var position_y : CGFloat = self.frame.size.height/2;
        var position_x : CGFloat = self.frame.size.width/2; // Assuming that width == height
        var retVal : UIBezierPath = UIBezierPath(arcCenter:CGPointMake(position_x, position_y), radius : position_y, startAngle : CGFloat((-M_PI/2)), endAngle : CGFloat((3*M_PI/2)),  clockwise : true)
        return retVal.CGPath
        
    }
    
    func setElapsedTime(elapsedTime : NSTimeInterval) {
        self.initialProgress = self.calculatePercent(self.elapsedTime, toTime : self.timeLimit)
        self.elapsedTime = elapsedTime;
        
        self.progressLayer.strokeEnd = CGFloat(self.percent)
        self.startAnimation();

    }
    
    var percent : Double {
        get {
            self._percent = self.calculatePercent(self.elapsedTime, toTime : self.timeLimit)
            return self._percent;
        }
    }
    
    var progressColor : CGColor {
        get {
            return self.progressLayer.strokeColor
        }
        set {
            self.progressLayer.strokeColor = newValue
        }

    }
    
    func calculatePercent(fromTime : NSTimeInterval, toTime : NSTimeInterval ) -> Double {
        
        if ((toTime > 0) && (fromTime > 0)) {
            
            var progress : CGFloat = 0;
            
            progress = CGFloat(fromTime / toTime)
            
            if ((progress * 100) > 100) {
                progress = 1.0;
            }
            
            return Double(progress);
        }
        else
        {
            return 0.0
        }
    }
    
    func startAnimation() {
        var pathAnimation : CABasicAnimation = CABasicAnimation(keyPath:"strokeEnd")
        pathAnimation.duration = 1.0;
        pathAnimation.fromValue = self.initialProgress;
        pathAnimation.toValue = self.percent
        pathAnimation.removedOnCompletion = true
        
        self.progressLayer.addAnimation(pathAnimation, forKey:nil)
        
    }
    
    
    
}