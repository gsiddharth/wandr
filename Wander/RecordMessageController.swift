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
    @IBOutlet weak var recordMessageButton: CircleProgressView! {
        didSet {
            self.recordMessageButton.setupViews()
            self.recordMessageButton.timeLimit = 3600
            self.recordMessageButton.status = "circle-progress-view.status-not-started"
            self.recordMessageButton.tintColor = UIColor.whiteColor()
            self.recordMessageButton.elapsedTime = 0
            
        }
    }
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var library : ALAssetsLibrary!
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    var videoCameraView : VideoCameraInputManager!
    
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
                self.recordMessageButton.backgroundColor = UIColor.greenColor()
                self.videoCameraView.resumeRecording()
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
        
        var file = FileUtils.videoFilePath()
        
        self.videoCameraView.finalizeRecordingToFile(file, withVideoSize: CGSize(width : self.videoPreviewView.frame.width, height : self.videoPreviewView.frame.height), withPreset: AVAssetExportPreset640x480, withCompletionHandler: {(error : NSError!) -> Void in
            
            if error == nil {
                FileUtils.addVideoToAlbum(self.library, videourl : file, album: Constants.albumName)
            } else {
                print("done exporting file")
            }
        })
        
    }

}
