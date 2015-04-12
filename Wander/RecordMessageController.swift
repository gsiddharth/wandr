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

class RecordMessageController: UIViewController {
    
    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var recordMessageButton: UIButton!
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    var videoCameraView : VideoCameraInputManager!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
                self.recordMessageButton.backgroundColor = UIColor.greenColor()
                self.videoCameraView.startRecording()
            } else {
                self.recordMessageButton.backgroundColor = UIColor.redColor()
                self.videoCameraView.pauseRecording()
            }
        } else {
            self.recordMessageButton.backgroundColor = UIColor.greenColor()
            self.videoCameraView.startRecording()
        }
    }
    
    
    @IBAction func onDoneRecording(sender: AnyObject) {
        self.videoCameraView.finalizeRecordingToFile(videoFilePath(), withVideoSize: self.videoPreviewView.intrinsicContentSize(), withPreset: AVCaptureSessionPreset640x480, withCompletionHandler: nil)
    }

    func videoFilePath() -> NSURL! {
        var sharedFM : NSFileManager = NSFileManager.defaultManager()
        var possibleURLs = sharedFM.URLsForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        var appSupportDir : NSURL! = nil
        var appDirectory : NSURL! = nil
        
        if possibleURLs.count >= 1 {
            appSupportDir = possibleURLs[0] as! NSURL
        }
        
        if appSupportDir != nil {
            var appBundleID : String! = NSBundle.mainBundle().bundleIdentifier
            appDirectory = appSupportDir.URLByAppendingPathComponent(appBundleID)
        }
        
        if appDirectory != nil {
            var file =  appDirectory.URLByAppendingPathComponent( NSDate().timeIntervalSince1970.description)
            return file
        }
        
        return nil
        
    }
}
