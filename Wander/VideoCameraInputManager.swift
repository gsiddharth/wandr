//
//  VideoCameraInputManager.swift
//  Wander
//
//  Created by Siddharth Garg on 29/03/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//


import UIKit
import AVFoundation

class VideoCameraInputManager : AVCaptureFileOutputRecordingDelegate {
    var setupComplete : Bool = false
    var videoInput : AVCaptureDeviceInput!
    var audioInput : AVCaptureDeviceInput!
    var movieFileOutput : AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    var orientation : AVCaptureVideoOrientation?
    
    var temporaryFileURLs = [NSURL]()
    
    var uniqueTimeStamp : NSTimeInterval?
    var currentRecordingSegment : Int32?
    
    var currentFinalDuration : CMTime?
    var inFlightWrites : Int32 = 0
    var isPaused : Bool = false
    var maxDuration : Float64 = 0
    var captureSession : AVCaptureSession!
    
    func setupSessionWithPreset(preset : String, withCaptureDevice cd : AVCaptureDevicePosition, withTorchMode tm : AVCaptureTorchMode, withError error : NSError){
        
        if setupComplete {
            return
        }
        
        var captureDevice : AVCaptureDevice = self.cameraWithPosition(cd)
        
        if captureDevice.hasTorch {
            if captureDevice.lockForConfiguration(nil) {
                if captureDevice.isTorchModeSupported(tm) {
                    captureDevice.setTorchModeOnWithLevel(0.1, error: nil)
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
    
    func startRecording() {
        
        self.temporaryFileURLs.removeAll(keepCapacity: true)
        self.uniqueTimeStamp = NSDate().timeIntervalSince1970
        self.currentRecordingSegment = 0
        self.isPaused = false
        self.currentFinalDuration = kCMTimeZero
        
        var videoConnection : AVCaptureConnection = self.connectionWithMediaType(AVMediaTypeVideo, fromConnections: movieFileOutput.connections)
        
        if videoConnection.supportsVideoOrientation {
            videoConnection.videoOrientation = self.orientation!
        }
        
        var outputFileURL : NSURL! = NSURL(fileURLWithPath: self.constructCurrentTemporaryFilename())
        temporaryFileURLs.append(outputFileURL)
        if self.maxDuration > 0 {
            self.movieFileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(self.maxDuration, 600)
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
        self.isPaused = false
        var outputFileURL : NSURL! = NSURL.fileURLWithPath(self.constructCurrentTemporaryFilename())
        
        temporaryFileURLs.append(outputFileURL)
        if self.maxDuration > 0 {
            movieFileOutput.maxRecordedDuration = CMTimeSubtract(CMTimeMakeWithSeconds(self.maxDuration, 600), self.currentFinalDuration!)
        } else {
            movieFileOutput.maxRecordedDuration = kCMTimeInvalid
        }
        
        movieFileOutput.startRecordingToOutputFileURL(outputFileURL, recordingDelegate: self)
    }
    
    func reset() {
        if self.movieFileOutput.recording {
            self.pauseRecording()
        }
        
        self.isPaused = false
    }
    
    func finalizeRecordingToFile(finalVideoLocationURL : NSURL, withVideoSize videoSize : CGSize, withPreset preset : String) {
        self.reset()
        var error = NSErrorPointer()
        
        if finalVideoLocationURL.checkResourceIsReachableAndReturnError(error) {
            return
        }
        
        if inFlightWrites != 0 {
            return
        }
        
        AVAssetSti
    }
    
    func totalRecordingDuration() -> CMTime {
        
    }
    
    private func startNotificationObserver() {
        
    }
    
    private func endNotificationObservers() {
        
    }
    
    private func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice{
        
    }
    
    private func audioDevice() -> AVCaptureDevice {
        
    }
    
    private func connectionWithMediaType(mediaType : String, fromConnections connections : [AnyObject]) -> AVCaptureConnection{
        
    }
    
    private func constructCurrentTemporaryFilename() -> String{
        
    }
    
    private func cleanTemporaryFiles() {
        
    }
    
}