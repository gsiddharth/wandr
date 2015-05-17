//
//  RecordMessageController.swift
//  Wander
//
//  Created by Siddharth Garg on 22/02/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import QuartzCore
import PBJVision

class RecordMessageController: UIViewController, PBJVisionDelegate {
    
    @IBOutlet weak var videoPreviewView: UIView!

    var library : ALAssetsLibrary!
    
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var doneVideoRecordingButton: UIBarButtonItem! {
        didSet {
            self.doneVideoRecordingButton.enabled = false
        }
    }
    
    
    @IBOutlet weak var recordMessageButton: CircleProgressButton! {
        didSet {
            self.recordMessageButton.timeLimit = Constants.maxVideoDurationInSec as NSTimeInterval
            self.recordMessageButton.status = "circle-progress-view.status-not-started"
            self.recordMessageButton.tintColor = UIColor.redColor()
            self.recordMessageButton.elapsedTime = 0
            
        }
    }
    
    
    @IBOutlet weak var stopButton: UIButton! {
        didSet {
            self.stopButton.layer.cornerRadius = 5
            self.stopButton.clipsToBounds = true
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.library = ALAssetsLibrary()
        
        self.setupPreview()
        
        self.setupCamera()

    }
    
    func setupPreview() {
        self.navigationController!.navigationBar.translucent = false;
        self.videoPreviewView.backgroundColor = UIColor.blackColor()
        var previewLayer = PBJVision.sharedInstance().previewLayer
        previewLayer.frame = self.videoPreviewView.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.videoPreviewView.layer.addSublayer(previewLayer)
    }
    
    func setupCamera() {
        var vision = PBJVision.sharedInstance()
        vision.delegate = self
        vision.cameraMode = PBJCameraMode.Video
        vision.cameraOrientation = PBJCameraOrientation.Portrait
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        vision.outputFormat = PBJOutputFormat.Square
        vision.maximumCaptureDuration = CMTimeMakeWithSeconds(Float64(Constants.maxVideoDurationInSec), Constants.videoFramesPerSec)
        vision.startPreview()
    }

    @IBAction func onRecordMessageButtonPress(sender: AnyObject) {

        var vision = PBJVision.sharedInstance()

        if vision.capturedVideoSeconds > 0 {
            if vision.paused {
                vision.resumeVideoCapture()
            } else {
                vision.pauseVideoCapture()
            }
        } else {
            vision.startVideoCapture()
        }
    }
    
    
    @IBAction func onStopButtonPress(sender: AnyObject) {
        var vision = PBJVision.sharedInstance()
        vision.cancelVideoCapture()
        self.recordMessageButton.reload()
    }
    
    func pauseRecording() {
        var vision = PBJVision.sharedInstance()
        vision.pauseVideoCapture()
    }
    
    
    func visionDidStartVideoCapture(vision: PBJVision) {
        self.doneVideoRecordingButton.enabled = false
        self.recordMessageButton.pressed = true
        self.update()
    }
    
    func visionDidPauseVideoCapture(vision: PBJVision) {
        self.doneVideoRecordingButton.enabled = true
        self.recordMessageButton.pressed = false
    }

    func visionDidResumeVideoCapture(vision: PBJVision) {
        self.doneVideoRecordingButton.enabled = false
        self.recordMessageButton.pressed = true
    }

    func visionDidEndVideoCapture(vision: PBJVision) {
        self.doneVideoRecordingButton.enabled = true
        self.recordMessageButton.pressed = false
        self.recordMessageButton.enabled = false
    }
    

    func vision(vision: PBJVision, capturedVideo videoDict: [NSObject : AnyObject]?, error: NSError?) {

        
        if error != nil  && error!.domain == PBJVisionErrorDomain && error!.code == PBJVisionErrorType.Cancelled.rawValue {
            NSLog("recording session cancelled")
            return
        } else if error != nil {
            NSLog("encounted an error in video capture (%@)", error!)
            return
        }
        
        var videoPath : String = videoDict?[PBJVisionVideoPathKey] as! String
        
        FileUtils.addVideoToAlbum(self.library, videourl : NSURL(fileURLWithPath: videoPath), album: Constants.albumName)
        
        loadReviewVideoController(videoPath)
        
    }
    
    func loadReviewVideoController(videoFilePath : String){
        
        var reviewVideoController : ReviewVideoController = self.storyboard?.instantiateViewControllerWithIdentifier("reviewVideoController") as! ReviewVideoController
        reviewVideoController.setVideoFilePath(videoFilePath)
        
        var navigationController : UINavigationController = UINavigationController(rootViewController: reviewVideoController)
        
        self.presentViewController(navigationController, animated: true, completion: nil)

    }
    
    func update() {
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
            
            var vision = PBJVision.sharedInstance()
            
            while vision.recording || vision.paused {
                var newTime = vision.capturedVideoSeconds as NSTimeInterval
                dispatch_async(dispatch_get_main_queue()) {
                    self.recordMessageButton.elapsedTime = newTime
                }
                sleep(1)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "recordToReviewSegue" {
            var vision = PBJVision.sharedInstance()
            vision.endVideoCapture()
            return false
        }
        
        return true
    }

}
