//
//  Convertors.swift
//  Wander
//
//  Created by Siddharth Garg on 16/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation

class Convertors {
    static func convertCGColorToUIColor (cgColor : CGColor!) -> UIColor! {
        return UIColor(CGColor: cgColor)
    }
    
    static func convertUIColorToCGColor(uiColor : UIColor) -> CGColor {
        return uiColor.CGColor
    }
}