//
//  FileUtils.swift
//  Wander
//
//  Created by Siddharth Garg on 14/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation
import AVFoundation

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
                library.assetForURL(url, resultBlock: { (asset : ALAsset!) -> Void in
                    groupToAddTo.addAsset(asset)
                    }, failureBlock: { (error : NSError!) -> Void in
                        NSLog("Failed to add to album")
                })
            }
        })
    }

    static func getAllVideo(library : ALAssetsLibrary!, album : String, withOnGetVideo onGetVideo : ((NSURL) ->Void)!){

        var groupToSearchIn : ALAssetsGroup!
        
        library.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupAlbum), usingBlock: { (group : ALAssetsGroup!, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
            if group != nil {
                if group!.valueForProperty(ALAssetsGroupPropertyName) as! String == album {
                    group.enumerateAssetsUsingBlock({ (result : ALAsset!, index : Int, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
                    
                        if result != nil {
                            if result.valueForProperty(ALAssetPropertyType) as! String == ALAssetTypeVideo {
                                var url : NSURL = result.defaultRepresentation().url()
                                onGetVideo(url)
                            }
                        }
                        
                    })
                }
            }
            }, failureBlock : { (error : NSError!) -> Void in
                
                NSLog("Failed to capture group")
        })
    }
    
    static func generateThumbnail(url : NSURL!, size : CGSize) -> UIImage {
        var asset : AVAsset = AVAsset.assetWithURL(url) as! AVAsset
        var assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        var error : NSError? = nil
        var time : CMTime = CMTimeMake(1, 30)
        var img : CGImageRef = assetImgGenerate.copyCGImageAtTime(time, actualTime: nil, error: &error)
        var frameImg : UIImage = UIImage(CGImage: img)!
        var scaledImage = FileUtils.imageWithImage(frameImg, scaledToSize : size)
        return scaledImage
    }
    
    static func imageWithImage (image : UIImage, scaledToSize newSize : CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0,0, newSize.width, newSize.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}