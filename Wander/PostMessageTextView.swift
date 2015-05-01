//
//  PostMessageTextView.swift
//  Wander
//
//  Created by Siddharth Garg on 01/05/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation
import UIKit

class PostMessageTextView: UITextView, UITextViewDelegate {

    var _alignMiddleVertical = false
    

    required init(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        self.alignMiddleVertical = true
        self.delegate = self
    }
    
    var alignMiddleVertical: Bool {
        get {
            return self._alignMiddleVertical
        }
        set {
            if newValue {
                self.addObserver(self, forKeyPath:"contentSize", options:.New, context:nil)
            }
            self._alignMiddleVertical = newValue
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject:AnyObject], context: UnsafeMutablePointer<Void>) {
        if let textView = object as? UITextView {
            var y: CGFloat = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale)/2.0;
            if y < 0 {
                y = 0
            }
            textView.contentOffset = CGPoint(x: 0, y: -y)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.resignFirstResponder()
    }



}
