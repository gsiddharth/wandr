//
//  NetworkingUtils.swift
//  Wander
//
//  Created by Siddharth Garg on 17/05/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation
import SwiftHTTP

class Networking {
    
    static var INSTANCE : Networking = Networking()
    
    static var instance : Networking {
        get {
            return Networking.INSTANCE
        }
    }

    var _server : String = "192.168.0.100"
    var server : String {
        get {
            return _server
        }
        
        set {
            _server = newValue
        }
    }
    
    var _port : Int32 = 3000
    var port : Int32 {
        get {
            return _port
        }
        
        set {
            _port = newValue
        }
    }
    
    var _sessionSecret : String = ""
    var sessionSecret : String {
        get{
            if _sessionSecret != "" {
                return _sessionSecret
            }else {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let val = defaults.stringForKey("session_secret") {
                    _sessionSecret = val
                    return val
                } else {
                    return ""
                }
            }
        }
        
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            _sessionSecret = newValue
            defaults.setObject(newValue, forKey : "session_secret")
        }
    }
    
    
    var _sessionKey : String = ""
    var sessionKey : String {
        get{
            if _sessionKey != "" {
                return _sessionKey
            }else {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let val = defaults.stringForKey("session_key") {
                    _sessionKey = val
                    return val
                } else {
                    return ""
                }
            }
        }
        
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            _sessionKey = newValue
            defaults.setObject(newValue, forKey : "session_key")
        }
    }
    
    var sessionKeyHeader : String = "X-Auth-Key"
    
    var sessionSecretHeader : String = "X-Auth-Secret"
    
    func setRequestHeaders(inout task : HTTPTask) {
        task.requestSerializer.headers[sessionKeyHeader] = sessionKey
        task.requestSerializer.headers[sessionSecretHeader] = sessionSecretHeader
    }
    
    func getRegisterURL(username: String, name : String, password : String, email :String, phone :String, gender : String) -> String {
        var encoded_name = name.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        var encoded_phone = phone.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        var st : String = "http://" + server + ":" + String(port) + "/register/" + username + "/" + password + "/" + encoded_name + "/" + email + "/" + encoded_phone + "/" + gender
        
        return st
    }
    
    func getLoginURL(username : String, password : String) -> String {
        var st : String = "http://" + server + ":" + String(port) + "/login/" + username + "/" + password
        
        return st
    }
    
    
    func getVideoUploadURL() -> String {
        var st : String = "http://" + server + ":" + String(port) + "/video"
        
        return st
    }

}