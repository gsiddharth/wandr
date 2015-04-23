//
//  FileUtils.swift
//  Wander
//
//  Created by Siddharth Garg on 14/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation

class FileUtils {
    
    static func videoFilePath() -> NSURL! {
        var sharedFM : NSFileManager = NSFileManager.defaultManager()
        var possibleURLs = sharedFM.URLsForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        var appSupportDir : NSURL!
        var appDirectory : NSURL!
        
        if possibleURLs.count >= 1 {
            appSupportDir = possibleURLs[0] as! NSURL
        }
        
        if appSupportDir != nil {
            var appBundleID : String! = NSBundle.mainBundle().bundleIdentifier
            appDirectory = appSupportDir.URLByAppendingPathComponent(appBundleID)
        }
        
        
        if appDirectory != nil {
            
            var url : NSURL = appDirectory
            
            if !sharedFM.fileExistsAtPath(appDirectory.path!) {
                sharedFM.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            
            var file =  appDirectory.URLByAppendingPathComponent( NSDate().timeIntervalSince1970.description + ".mov")
            return file
        }
        
        return nil
    }

    
    static func addVideoToAlbum(library : ALAssetsLibrary!, videourl : NSURL!, album : String){
        
        library.addAssetsGroupAlbumWithName(album, resultBlock: { (group : ALAssetsGroup!) -> Void in
            
            NSLog("added album " + album)
            
            }) { (erro : NSError!) -> Void in
                
                NSLog("failed to add album " + album)
        }
        
        var groupToAddTo : ALAssetsGroup!
        
        library.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupAlbum), usingBlock: { (group : ALAssetsGroup!, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
            if group != nil {
                if group!.valueForProperty(ALAssetsGroupPropertyName) as! String == album {
                    groupToAddTo = group
                }
            }
            }, failureBlock : { (error : NSError!) -> Void in
                
                NSLog("Failed to capture group")
        })
        
        library.writeVideoAtPathToSavedPhotosAlbum(videourl, completionBlock: { (url : NSURL!, error: NSError!) -> Void in
            
            if error == nil || error.code == 0 {
                NSLog("Adding ot the group")
                library.assetForURL(url, resultBlock: { (asset : ALAsset!) -> Void in
                    groupToAddTo.addAsset(asset)
                    }, failureBlock: { (error : NSError!) -> Void in
                        NSLog("Failed to add to album")
                })
            }
        })
    }

}