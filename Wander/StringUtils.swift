//
//  StringUtils.swift
//  Wander
//
//  Created by Siddharth Garg on 10/05/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation

class StringUtils {
    
    static func validEmail(email : String) -> Bool {
        var expression : String = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
        
        var regex = NSRegularExpression(pattern: expression, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
        
        var matchRange = regex.rangeOfFirstMatchInString(email, options: nil, range: NSMakeRange(0, count(email)))
        
        let valid = matchRange.location != NSNotFound
        
        return valid
        
    }
    
}