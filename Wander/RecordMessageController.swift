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

class RecordMessageController: UIViewController {
    
    @IBOutlet weak var videoPreviewView: UIView!
    
    var size : CGSize!
    
    @IBOutlet weak var doneVideoRecordingButton: UIBarButtonItem! {
        didSet {
            self.doneVideoRecordingButton.enabled = false
        }
    }
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer? {
        didSet {
            
        }
    }
    var library : ALAssetsLibrary!
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    var videoCameraView : VideoCameraInputManager!
    
    @IBOutlet weak var recordMessageButton: CircleProgressButton! {
        didSet {
            self.recordMessageButton.timeLimit = 60
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
        
        var err : NSError! = nil
        self.videoCameraView = VideoCameraInputManager()    
        self.videoCameraView.setupSessionWithPreset(AVCaptureSessionPresetHigh, withCaptureDevice: AVCaptureDevicePosition.Back, withTorchMode: AVCaptureTorchMode.Off, withError: &err)
        self.size = self.videoCameraView.startPreview(self.videoPreviewView)
        println(self.size.height.description + " " + self.size.width.description)
        println(self.view.frame.size.height.description + " " + self.view.frame.size.width.description)
        self.size = CGSizeMake(self.size.height, self.size.width)

    }

    @IBAction func onRecordMessageButtonPress(sender: AnyObject) {

        if self.videoCameraView.isStarted {
            if self.videoCameraView.isPaused {
                self.videoCameraView.resumeRecording()
                self.doneVideoRecordingButton.enabled = false
            } else {
                self.pauseRecording()
            }
        } else {
            self.videoCameraView.startRecording()
            self.doneVideoRecordingButton.enabled = false
            self.updateRecordingTime()
        }
    }
    
    
    @IBAction func onStopButtonPress(sender: AnyObject) {
        self.videoCameraView.reset()
        self.recordMessageButton.reload()
    }
    
    func pauseRecording() {
        self.videoCameraView.pauseRecording()
        self.doneVideoRecordingButton.enabled = true
    }
    
    func updateRecordingTime() {
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
            
            var lastTime = self.recordMessageButton.elapsedTime

            while self.videoCameraView.isStarted {
                
                var newTime = CMTimeGetSeconds(self.videoCameraView.totalRecordingDuration()) as NSTimeInterval
           
                if newTime - lastTime >= 1 {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.recordMessageButton.elapsedTime = newTime
                        lastTime = newTime
                    }
                }
                
                if newTime >= 60 {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.pauseRecording()
                        self.recordMessageButton.finish()
                    }
                    break
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "recordToPostSegue" {
            self.onDoneRecording(self)
            return false
        }
        
        return true
    }
    
    var added : Bool = false
    var addError : Bool = false
    
    func onDoneRecording(sender: AnyObject) {
        
        var file = FileUtils.videoFilePath()
        self.videoCameraView.pauseRecording()
        Messages.lastVideoFile = file
        
        self.videoCameraView.finalizeRecordingToFile(file, withVideoSize: self.size, withPreset: AVAssetExportPresetHighestQuality, withCompletionHandler: {(error : NSError!) -> Void in
            
            if error == nil {
                
                FileUtils.addVideoToAlbum(self.library, videourl : file, album: Constants.albumName)
                
                var postVideoController : PostVideoController = self.storyboard?.instantiateViewControllerWithIdentifier("postVideoController") as! PostVideoController
                var navigationController : UINavigationController = UINavigationController(rootViewController: postVideoController)
                self.presentViewController(navigationController, animated: true, completion: nil)

            } else {
                NSLog("error exporting file")
                self.addError = true
            }
        })
    }

}
