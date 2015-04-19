//
//  VideoCameraInputManager.swift
//  Wander
//
//  Created by Siddharth Garg on 29/03/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//


import UIKit
import AVFoundation

extension CMTime {
    var isValid:Bool { return (flags & .Valid) != nil }
}

class VideoCameraInputManager : NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var setupComplete : Bool = false
    var videoInput : AVCaptureDeviceInput!
    var audioInput : AVCaptureDeviceInput!
    var movieFileOutput : AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    var orientation : AVCaptureVideoOrientation? = AVCaptureVideoOrientation.Portrait
    
    var temporaryFileURLs = [NSURL]()
    
    var uniqueTimeStamp : NSTimeInterval?
    var currentRecordingSegment : Int32?
    
    var currentFinalDuration : CMTime?
    var inFlightWrites : Int32 = 0
    var isPaused : Bool = false
    var isStarted : Bool = false
    var maxDuration : Float64 = 0
    var captureSession : AVCaptureSession!
    var asyncErrorHandler : ((NSError!) -> Void)!
    
    var deviceConnectedObserver : NSObjectProtocol!
    var deviceDisconnectedObserver : NSObjectProtocol!
    var deviceOrientationDidChangeObserver : NSObjectProtocol!
    
    
    func setupSessionWithPreset(preset : String, withCaptureDevice cd : AVCaptureDevicePosition, withTorchMode tm : AVCaptureTorchMode, inout withError error : NSError!){
        
        if setupComplete {
            error = NSError(domain : "Setup session already complete", code: 102, userInfo: nil)
            return
        }
        
        var captureDevice : AVCaptureDevice = self.cameraWithPosition(cd)
        
        if captureDevice.hasTorch {
            if captureDevice.lockForConfiguration(nil) {
                if captureDevice.isTorchModeSupported(tm) {
                   captureDevice.torchMode = tm
                }
                captureDevice.unlockForConfiguration()
            }
        }
        
        self.captureSession = AVCaptureSession()
        self.captureSession!.sessionPreset = preset
        
        self.videoInput = AVCaptureDeviceInput(device:captureDevice, error: nil)
        if self.captureSession!.canAddInput(self.videoInput) {
            self.captureSession!.addInput(videoInput)
        }
        
        self.audioInput = AVCaptureDeviceInput(device:self.audioDevice(), error: nil)
        if self.captureSession!.canAddInput(self.audioInput) {
            self.captureSession!.addInput(self.audioInput)
        }
        
        if self.captureSession!.canAddOutput(self.movieFileOutput) {
           self.captureSession!.addOutput(movieFileOutput)
        }
    }
    
    func startPreview(previewView : UIView!) {
        
        var err : NSError? = nil
        
        var avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        avPreviewLayer.frame = previewView.bounds
        avPreviewLayer.position = CGPointMake(CGRectGetMidX(previewView.bounds), CGRectGetMidY(previewView.bounds))
        avPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        previewView.layer.addSublayer(avPreviewLayer)
        captureSession.startRunning()
        
    }
    
    func startRecording() {
        
        self.temporaryFileURLs.removeAll(keepCapacity: true)
        self.uniqueTimeStamp = NSDate().timeIntervalSince1970
        self.currentRecordingSegment = 0
        self.isPaused = false
        self.isStarted = true
        self.currentFinalDuration = kCMTimeZero
        
        var videoConnection : AVCaptureConnection = self.connectionWithMediaType(AVMediaTypeVideo, fromConnections: movieFileOutput.connections)
        
        if videoConnection.supportsVideoOrientation {
            videoConnection.videoOrientation = self.orientation!
        }
        
        var outputFileURL : NSURL! = NSURL(fileURLWithPath: self.constructCurrentTemporaryFilename())
        temporaryFileURLs.append(outputFileURL)
        if self.maxDuration > 0 {
            self.movieFileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(self.maxDuration, 60)
        } else {
            self.movieFileOutput.maxRecordedDuration = kCMTimeInvalid
        }
     
        self.movieFileOutput.startRecordingToOutputFileURL(outputFileURL, recordingDelegate: self)
        
    }
    
    func pauseRecording() {
        self.isPaused = true
        self.movieFileOutput.stopRecording()
        self.currentFinalDuration = CMTimeAdd(self.currentFinalDuration!, movieFileOutput.recordedDuration)
    }
    
    func resumeRecording() {
        self.currentRecordingSegment!++
        var outputFileURL : NSURL! = NSURL.fileURLWithPath(self.constructCurrentTemporaryFilename())
        
        temporaryFileURLs.append(outputFileURL)
        if self.maxDuration > 0 {
            movieFileOutput.maxRecordedDuration = CMTimeSubtract(CMTimeMakeWithSeconds(self.maxDuration, 600), self.currentFinalDuration!)
        } else {
            movieFileOutput.maxRecordedDuration = kCMTimeInvalid
        }
        
        movieFileOutput.startRecordingToOutputFileURL(outputFileURL, recordingDelegate: self)
        self.isPaused = false
    }
    
    func reset() {
        if self.movieFileOutput.recording {
            self.movieFileOutput.stopRecording()
        }
        
        self.inFlightWrites = 0
        self.currentFinalDuration = kCMTimeZero
        self.cleanTemporaryFiles()
        self.isPaused = false
        self.isStarted = false
    }
    
    func finalizeRecordingToFile(finalVideoLocationURL : NSURL, withVideoSize videoSize : CGSize, withPreset preset : String,
        withCompletionHandler completionHandler : ((NSError!) -> Void)!) {

            var error = NSErrorPointer()
            
            if finalVideoLocationURL.checkResourceIsReachableAndReturnError(error) {
                return
            }
            
            if inFlightWrites != 0 {
                return
            }
            
            var stitcher : AVAssetStitcher = AVAssetStitcher(outSize : videoSize)
            var stitcherError : NSError!
            
            for url in temporaryFileURLs.reverse() {
                stitcher.addAsset(AVURLAsset(URL:url, options: nil), withTransform: { (videoTrack: AVAssetTrack) -> CGAffineTransform in
                    var ratioW : CGFloat = videoSize.width / videoTrack.naturalSize.width
                    var ratioH : CGFloat = videoSize.height / videoTrack.naturalSize.height
                    
                    if ratioW < ratioH {
                        var neg : CGFloat = -1.0
                        if ratioH > 1.0 {
                            neg = 1.0
                        }
                        
                        var diffH : CGFloat = videoTrack.naturalSize.height - (videoTrack.naturalSize.height * ratioH)
                        return CGAffineTransformConcat(CGAffineTransformMakeTranslation(0.0, neg*diffH/2.0), CGAffineTransformMakeScale(ratioH, ratioH))
                    } else {
                        var neg : CGFloat = -1.0
                        if ratioW > 1.0 {
                            neg = 1.0
                        }
                        
                        var diffW : CGFloat =  videoTrack.naturalSize.width - (videoTrack.naturalSize.width * ratioW)
                        return CGAffineTransformConcat(CGAffineTransformMakeTranslation(neg * diffW / 2.0, 0.0), CGAffineTransformMakeScale(ratioW, ratioW))
                        
                    }
                    
                    }, withErrorHandler: { (err : NSError) -> Void in
                        stitcherError = err
                        return
                })
            }
            
            if stitcherError != nil {
                completionHandler(stitcherError)
                return
            }
            
            stitcher.exportTo(finalVideoLocationURL, withPreset: preset) { (error : NSError!) -> Void in
                if error != nil {
                    completionHandler(error)
                } else {
                    self.cleanTemporaryFiles()
                    self.temporaryFileURLs.removeAll(keepCapacity : false)
                    completionHandler(nil)
                }
            }
            
//            self.reset()
    }
    
    func totalRecordingDuration() -> CMTime {
        if CMTimeCompare(kCMTimeZero, self.currentFinalDuration!) == 0 {
            if movieFileOutput.recording {
                return movieFileOutput.recordedDuration
            } else {
                return self.currentFinalDuration!
            }
        } else {

            if !self.isPaused && movieFileOutput.recording{
                var returnTime : CMTime = CMTimeAdd(self.currentFinalDuration!, movieFileOutput.recordedDuration)
                if !returnTime.isValid {
                    return self.currentFinalDuration!
                } else {
                    return returnTime
                }
            }
            else {
                return self.currentFinalDuration!
            }
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        self.inFlightWrites++;
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if error != nil {
            if self.asyncErrorHandler != nil {
                self.asyncErrorHandler(error)
            } else {
                NSLog("Error capturing output" + error.localizedDescription)
            }
        }
        
        inFlightWrites--
    }
    
    private func startNotificationObserver() {
        
        var notificationCenter : NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        self.deviceConnectedObserver = notificationCenter.addObserverForName(AVCaptureDeviceWasConnectedNotification, object: nil, queue: nil) { (notification : NSNotification!) -> Void in
            var device : AVCaptureDevice = notification.object as! AVCaptureDevice
            var deviceMediaType : String! = ""
            if device.hasMediaType(AVMediaTypeAudio) {
                deviceMediaType = AVMediaTypeAudio
            } else if device.hasMediaType(AVMediaTypeVideo) {
                deviceMediaType = AVMediaTypeVideo
            }
            
            if deviceMediaType != nil {
                for (idx, value) in enumerate(self.captureSession.inputs) {
                    var input : AVCaptureDeviceInput = value as! AVCaptureDeviceInput
                    if input.device.hasMediaType(deviceMediaType) {
                        var error : NSError? = NSError()
                        var deviceInput : AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as! AVCaptureDeviceInput
                        if self.captureSession.canAddInput(deviceInput) {
                            self.captureSession.addInput(deviceInput)
                        }
                        
                        if error != nil {
                            if self.asyncErrorHandler != nil {
                                self.asyncErrorHandler(error)
                            } else {
                                NSLog("Error reconnecting devices" + error!.localizedDescription)
                            }
                        }
                        
                        break
                    }
                }
            }
        }
        
        self.deviceDisconnectedObserver = notificationCenter.addObserverForName(AVCaptureDeviceWasDisconnectedNotification, object: nil, queue: nil, usingBlock: { (notification : NSNotification!) -> Void in
            var device : AVCaptureDevice = notification.object as! AVCaptureDevice
            
            if device.hasMediaType(AVMediaTypeAudio) {
                self.captureSession.removeInput(self.audioInput)
                self.audioInput = nil
            } else if device.hasMediaType(AVMediaTypeVideo) {
                self.captureSession.removeInput(self.videoInput)
                self.videoInput = nil
            }
        })
        
        self.orientation = AVCaptureVideoOrientation.Portrait
        
        self.deviceOrientationDidChangeObserver = notificationCenter.addObserverForName(UIDeviceOrientationDidChangeNotification, object: nil, queue: nil, usingBlock: { (note : NSNotification!) -> Void in
            var currOrientation = UIDevice.currentDevice().orientation
            
            if currOrientation == UIDeviceOrientation.Portrait {
                self.orientation = AVCaptureVideoOrientation.Portrait
            } else if currOrientation == UIDeviceOrientation.PortraitUpsideDown {
                self.orientation = AVCaptureVideoOrientation.PortraitUpsideDown
            } else if currOrientation == UIDeviceOrientation.LandscapeLeft {
                self.orientation = AVCaptureVideoOrientation.LandscapeLeft
            } else if currOrientation == UIDeviceOrientation.LandscapeRight {
                self.orientation = AVCaptureVideoOrientation.LandscapeRight
            } else {
                self.orientation = AVCaptureVideoOrientation.Portrait
            }
            
        })
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        
    }
    
    private func endNotificationObservers() {
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
        
        NSNotificationCenter.defaultCenter().removeObserver(self.deviceConnectedObserver)
        NSNotificationCenter.defaultCenter().removeObserver(self.deviceDisconnectedObserver)
        NSNotificationCenter.defaultCenter().removeObserver(self.deviceOrientationDidChangeObserver)
    }
    
    private func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice! {
        var foundDevice : AVCaptureDevice! = nil
        for (index, value) in enumerate(AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)) {
            var device : AVCaptureDevice = value as! AVCaptureDevice
            if device.position == position {
                foundDevice = device
                break
            }
        }
        
        return foundDevice
    }
    
    private func audioDevice() -> AVCaptureDevice! {
        var devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio)
        
        if devices.count > 0 {
            return devices[0] as! AVCaptureDevice
        }
        
        return nil
    }
    
    private func connectionWithMediaType(mediaType : String, fromConnections connections : [AnyObject]) -> AVCaptureConnection{
        var foundConnection : AVCaptureConnection! = nil
        
        for (index, value) in enumerate(connections) {
            var connection : AVCaptureConnection = value as! AVCaptureConnection
            var connectionStop: Bool = false
            for (index1, value1) in enumerate(connection.inputPorts) {
                var port : AVCaptureInputPort = value1 as! AVCaptureInputPort
                if port.mediaType == mediaType {
                    foundConnection = connection
                    connectionStop = true
                    break
                }
            }
            
            if connectionStop {
                break
            }
        }
        
        return foundConnection
    }
    
    private func constructCurrentTemporaryFilename() -> String {
        return NSTemporaryDirectory() + self.uniqueTimeStamp!.description + self.currentRecordingSegment!.description + ".mov"
    }
    
    private func cleanTemporaryFiles() {
        for (idx, val) in enumerate(self.temporaryFileURLs) {
            var temporaryFiles : NSURL = val as NSURL
            NSFileManager.defaultManager().removeItemAtURL(temporaryFiles, error: nil)
        }
    }
}