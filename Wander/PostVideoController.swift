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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setVideoFilePath(path : String) {
        videoFile = NSURL(fileURLWithPath: path)!
    }
    
    @IBAction func onPostButtonClick(sender: AnyObject) {
        var task = HTTPTask()
        println("uploading file")
        
        Networking.instance.setRequestHeaders(&task)
        
        task.uploadFile(Networking.instance.getVideoUploadURL(), parameters: ["video_file":  HTTPUpload(fileUrl: self.videoFile)], progress: { (value: Double) -> Void in
            println("progress: \(value)")
            }, success: { (response: HTTPResponse) -> Void in
                println("file uploaded successfully")
                self.loadHomeViewController()
                
            }) { (err : NSError) -> Void in
                println("error uploading file")
        }
    }
    
    func loadHomeViewController(){
        
        var homeViewController : HomeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("homeViewController") as! HomeViewController
        
        var navigationController : UINavigationController = UINavigationController(rootViewController: homeViewController)
        
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
}
