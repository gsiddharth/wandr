//
//  User.swift
//  Wander
//
//  Created by Siddharth Garg on 21/03/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation

class User {
    
    var username:String?
    var name:String?
    var email:String?
    var password:String?
    var authenticated:Bool?
    
    init() {
    
    }
    
    func authenticate(username : String, password : String) -> Errors {
        //if authentication successful set User params
        self.username = username
        return Errors.Success
    }
    
    func create(username : String, name : String, email : String, password : String) -> Errors {
        return Errors.Success
    }
    
    func logout() -> Errors {
        return Errors.Success
    }
    
    func delete() -> Errors {
        return Errors.Success
    }
}
