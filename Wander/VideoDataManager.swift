//
//  VideoDataManager.swift
//  Wander
//
//  Created by Siddharth Garg on 25/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation

class VideoDataManager {
    
    static var INSTANCE : VideoDataManager = VideoDataManager()
    
    var instance : VideoDataManager {
        get {
            return VideoDataManager.INSTANCE
        }
    }
    
    var videoURLs : [NSURL] = [NSURL]()
    
    func addVideo(url : NSURL) {
        videoURLs.append(url)
    }
    
}