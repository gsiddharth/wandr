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
    
    @IBOutlet weak var doneVideoRecordingButton: UIBarButtonItem!
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
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
        self.videoCameraView.setupSessionWithPreset(AVCaptureSessionPreset640x480, withCaptureDevice: AVCaptureDevicePosition.Back, withTorchMode: AVCaptureTorchMode.Off, withError: &err)
        self.videoCameraView.startPreview(self.videoPreviewView)

    }
    
    func beginSession() {
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.videoPreviewView.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.videoPreviewView.layer.frame
        captureSession.startRunning()
    }
        
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
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
            
            return true
            
        }
        
        return true
    }
    
    var added : Bool = false
    var addError : Bool = false
    
    func onDoneRecording(sender: AnyObject) {
        
        var file = FileUtils.videoFilePath()
        self.videoCameraView.pauseRecording()
        Messages.lastVideoFile = file

        self.videoCameraView.finalizeRecordingToFile(file, withVideoSize: CGSize(width : self.videoPreviewView.frame.width, height : self.videoPreviewView.frame.height), withPreset: AVAssetExportPreset640x480, withCompletionHandler: {(error : NSError!) -> Void in
            
            if error == nil {
                NSLog("adding to the album")
                FileUtils.addVideoToAlbum(self.library, videourl : file, album: Constants.albumName)
                NSLog("added to the album")

            } else {
                NSLog("error exporting file")
                self.addError = true
            }
        })
    }

}
