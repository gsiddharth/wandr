//
//  PostVideoController.swift
//  Wander
//
//  Created by Siddharth Garg on 01/05/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//


import UIKit
import Foundation
import SwiftHTTP

class PostVideoController: UIViewController, VideoMessageProcessorDelegate {

    @IBOutlet weak var messageTextView: PostMessageTextView!
    
    var videoFile : NSURL!
    var videoLength : Float64!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTextView.becomeFirstResponder()
    }
    
    func setVideoFilePath(path : String, length : Float64) {
        videoFile = NSURL(fileURLWithPath: path)!
        videoLength = length
    }
    
    @IBAction func onPostButtonClick(sender: AnyObject) {
        var task = HTTPTask()
        
        println("uploading file")
        
        Networking.instance.setRequestHeaders(&task)
        
        var thumbnail = FileUtils.generateThumbnail(self.videoFile, size: CGSizeMake(CGFloat(Constants.videoWidth), CGFloat(Constants.videoHeight)), isPortrait : true)
        
        var thumbnailData = UIImagePNGRepresentation(thumbnail)
        
        var params : Dictionary<String, AnyObject> = ["video_file":  HTTPUpload(fileUrl: self.videoFile), "video_extension" : "mov", "video_length" : String(stringInterpolationSegment: self.videoLength),
            "longitude" : "0", "latitude": "0", "city": "Mumbai",
            "thumbnail_file" : HTTPUpload(data: thumbnailData, fileName: "thumbanil.png", mimeType: "images/png"),
            "thumnail_extension" : "png", "thumbnail_width" : String(stringInterpolationSegment: Constants.videoWidth), "thumbnail_height" : String(stringInterpolationSegment: Constants.videoHeight)]
        
        task.upload(Networking.instance.getVideoUploadURL(), method: .POST, parameters: params, progress: { (value: Double) in
            println("progress: \(value)")
            }, completionHandler: { (response: HTTPResponse) in
                
                if let err = response.error {
                    println("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                
                if let data = response.responseObject as? NSData {
                    let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("response: \(str!)") //prints the response
                    println("file uploaded successfully")
                    self.loadHomeViewController()

                }
        })
        
    }
    
    func loadHomeViewController(){
        
        var homeViewController : HomeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("homeViewController") as! HomeViewController
        
        var navigationController : UINavigationController = UINavigationController(rootViewController: homeViewController)
        
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
}
