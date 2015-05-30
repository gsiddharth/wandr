//
//  Convertors.swift
//  Wander
//
//  Created by Siddharth Garg on 16/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation
import SwiftHTTP

class Convertors {
    static func convertCGColorToUIColor (cgColor : CGColor!) -> UIColor! {
        return UIColor(CGColor: cgColor)
    }
    
    static func convertUIColorToCGColor(uiColor : UIColor) -> CGColor {
        return uiColor.CGColor
    }
    
    static func toMap(response : HTTPResponse) -> (object: AnyObject?, error: NSError?){
        var error: NSError?
        if response.responseObject != nil {
            var data = (response.responseObject as? NSData)!
            var options = NSJSONReadingOptions.AllowFragments
        
            let resp:   AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: options, error: &error)
            return (resp, error)
        } else {
            return (nil, error)
        }
    }
}