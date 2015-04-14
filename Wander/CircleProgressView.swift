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
    
    override init(frame : CGRect) {
        super.init(frame : frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
    }
    
    override func awakeFromNib() {
        self.setupViews()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.progressLayer.frame = self.bounds
        
        self.progressLabel.sizeToFit()
        
        self.progressLabel.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    var _progressLabel : UILabel!
    var progressLabel : UILabel! {
        get {
            if self._progressLabel == nil {
                self._progressLabel = UILabel(frame: self.bounds)
                self._progressLabel.numberOfLines = 2;
                self._progressLabel.textAlignment = NSTextAlignment.Center
                self._progressLabel.backgroundColor = UIColor.clearColor()
                self._progressLabel.textColor = UIColor.whiteColor()
            
                self.addSubview(self._progressLabel)
            }
            
            return self._progressLabel
        }
    }
    
    var percent : Double! {
        get {
            return self.progressLayer.percent
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
    
    var _elapsedTime : NSTimeInterval!
    var elapsedTime : NSTimeInterval! {
        get {
            return _elapsedTime
        }
        set {
            _elapsedTime = newValue;
            self.progressLayer.elapsedTime = newValue;
            //self.progressLabel.attributedText = //self.formatProgressStringFromTimeInterval(newValue)
        }
    }

    func setupViews() {
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false;
        
        //add Progress layer
        self.progressLayer = CircleShapeLayer()
        self.progressLayer.frame = self.bounds;
        self.progressLayer.backgroundColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(self.progressLayer)
    }
    
    override var tintColor : UIColor! {
        get {
            return self.tintColor
        }
        
        set {
            super.tintColor = newValue
            self.progressLayer.progressColor = newValue!.CGColor;
            self.progressLabel.textColor = newValue!;
        }
    }
    
    func stringFromTimeInterval(interval : NSTimeInterval, shortDate: Bool) -> String {
        var ti : Int = Int(interval as Double)
        var seconds : Int = ti % 60;
        var minutes : Int = (ti / 60) % 60;
        var hours : Int = (ti / 3600);
        
        if (shortDate) {
            return String(format : "%02d:%02d", hours, minutes)
        }
        else {
            return String(format : "%02d:%02d:02d", hours, minutes, seconds)
        }
    }
    
    func formatProgressStringFromTimeInterval(interval : NSTimeInterval) -> NSAttributedString {
        var progressString : String = self.stringFromTimeInterval(interval, shortDate:false)
        
        var attributedString : NSMutableAttributedString!;
        
        if (count(self.status) > 0) {
            
            attributedString = NSMutableAttributedString(string : String(format:"%@\n%@", progressString, self.status))
            
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name : "HelveticaNeue-Bold", size:40)!, range:NSMakeRange(0, count(progressString)))
            
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name : "HelveticaNeue-thin", size:18)!, range:NSMakeRange(count(progressString)+1, count(self.status)))
            
        }
        else
        {
            attributedString = NSMutableAttributedString(string : String(format:"%@",progressString))
            
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name : "HelveticaNeue-Bold", size:18)!, range:NSMakeRange(0, count(progressString)))
        }
        
        return attributedString;

    }
    
    
}
