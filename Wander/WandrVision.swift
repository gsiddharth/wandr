//
//  WandrVision.swift
//  Wander
//
//  Created by Siddharth Garg on 30/04/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import Foundation



class WandrVision : NSObject {
    
    class func sharedInstance() -> WandrVision
    
    weak var delegate: PBJVisionDelegate
    
    // session
    
    var captureSessionActive: Bool { get }
    
    // setup
    
    var cameraOrientation: PBJCameraOrientation
    var cameraMode: PBJCameraMode
    var cameraDevice: PBJCameraDevice
    // Indicates whether the capture session will make use of the app’s shared audio session. Allows you to
    // use a previously configured audios session with a category such as AVAudioSessionCategoryAmbient.
    var usesApplicationAudioSession: Bool
    func isCameraDeviceAvailable(cameraDevice: PBJCameraDevice) -> Bool
    
    var flashMode: PBJFlashMode // flash and torch
    var flashAvailable: Bool { get }
    
    var mirroringMode: PBJMirroringMode
    
    // video output settings
    
    var captureSessionPreset: String
    var captureDirectory: String
    var outputFormat: PBJOutputFormat
    
    // video compression settings
    
    var videoBitRate: CGFloat
    var audioBitRate: Int
    var additionalCompressionProperties: [NSObject : AnyObject]
    
    // video frame rate (adjustment may change the capture format (AVCaptureDeviceFormat : FoV, zoom factor, etc)
    
    var videoFrameRate: Int // desired fps for active cameraDevice
    func supportsVideoFrameRate(videoFrameRate: Int) -> Bool
    
    // preview
    
    var previewLayer: AVCaptureVideoPreviewLayer { get }
    var autoUpdatePreviewOrientation: Bool
    var previewOrientation: PBJCameraOrientation
    var autoFreezePreviewDuringCapture: Bool
    
    var cleanAperture: CGRect { get }
    
    func startPreview()
    func stopPreview()
    
    func freezePreview()
    func unfreezePreview()
    
    // focus, exposure, white balance
    
    // note: focus and exposure modes change when adjusting on point
    func isFocusPointOfInterestSupported() -> Bool
    func focusExposeAndAdjustWhiteBalanceAtAdjustedPoint(adjustedPoint: CGPoint)
    
    var focusMode: PBJFocusMode
    var focusLockSupported: Bool { get }
    func focusAtAdjustedPointOfInterest(adjustedPoint: CGPoint)
    func isAdjustingFocus() -> Bool
    
    var exposureMode: PBJExposureMode
    var exposureLockSupported: Bool { get }
    func exposeAtAdjustedPointOfInterest(adjustedPoint: CGPoint)
    func isAdjustingExposure() -> Bool
    
    // photo
    
    var canCapturePhoto: Bool { get }
    func capturePhoto()
    
    // video
    // use pause/resume if a session is in progress, end finalizes that recording session
    
    var supportsVideoCapture: Bool { get }
    var canCaptureVideo: Bool { get }
    var recording: Bool { get }
    var paused: Bool { get }
    
    var videoRenderingEnabled: Bool
    var audioCaptureEnabled: Bool
    
    var context: EAGLContext { get }
    var presentationFrame: CGRect
    
    var maximumCaptureDuration: CMTime // automatically triggers vision:capturedVideo:error: after exceeding threshold, (kCMTimeInvalid records without threshold)
    var capturedAudioSeconds: Float64 { get }
    var capturedVideoSeconds: Float64 { get }
    
    func startVideoCapture()
    func pauseVideoCapture()
    func resumeVideoCapture()
    func endVideoCapture()
    func cancelVideoCapture()
    
    // thumbnails
    
    var thumbnailEnabled: Bool // thumbnail generation, disabling reduces processing time for a photo or video
    var defaultVideoThumbnails: Bool // capture first and last frames of video
    
    func captureCurrentVideoThumbnail()
    func captureVideoThumbnailAtFrame(frame: Int64)
    func captureVideoThumbnailAtTime(seconds: Float64)
}

protocol PBJVisionDelegate : NSObjectProtocol {
    
    // session
    
    optional func visionSessionWillStart(vision: PBJVision)
    optional func visionSessionDidStart(vision: PBJVision)
    optional func visionSessionDidStop(vision: PBJVision)
    
    optional func visionSessionWasInterrupted(vision: PBJVision)
    optional func visionSessionInterruptionEnded(vision: PBJVision)
    
    // device / mode / format
    
    optional func visionCameraDeviceWillChange(vision: PBJVision)
    optional func visionCameraDeviceDidChange(vision: PBJVision)
    
    optional func visionCameraModeWillChange(vision: PBJVision)
    optional func visionCameraModeDidChange(vision: PBJVision)
    
    optional func visionOutputFormatWillChange(vision: PBJVision)
    optional func visionOutputFormatDidChange(vision: PBJVision)
    
    optional func vision(vision: PBJVision, didChangeCleanAperture cleanAperture: CGRect)
    
    optional func visionDidChangeVideoFormatAndFrameRate(vision: PBJVision)
    
    // focus / exposure
    
    optional func visionWillStartFocus(vision: PBJVision)
    optional func visionDidStopFocus(vision: PBJVision)
    
    optional func visionWillChangeExposure(vision: PBJVision)
    optional func visionDidChangeExposure(vision: PBJVision)
    
    optional func visionDidChangeFlashMode(vision: PBJVision) // flash or torch was changed
    
    // authorization / availability
    
    optional func visionDidChangeAuthorizationStatus(status: PBJAuthorizationStatus)
    optional func visionDidChangeFlashAvailablility(vision: PBJVision) // flash or torch is available
    
    // preview
    
    optional func visionSessionDidStartPreview(vision: PBJVision)
    optional func visionSessionDidStopPreview(vision: PBJVision)
    
    // photo
    
    optional func visionWillCapturePhoto(vision: PBJVision)
    optional func visionDidCapturePhoto(vision: PBJVision)
    optional func vision(vision: PBJVision, capturedPhoto photoDict: [NSObject : AnyObject]?, error: NSError?)
    
    // video
    
    optional func vision(vision: PBJVision, willStartVideoCaptureToFile fileName: String) -> String
    optional func visionDidStartVideoCapture(vision: PBJVision)
    optional func visionDidPauseVideoCapture(vision: PBJVision) // stopped but not ended
    optional func visionDidResumeVideoCapture(vision: PBJVision)
    optional func visionDidEndVideoCapture(vision: PBJVision)
    optional func vision(vision: PBJVision, capturedVideo videoDict: [NSObject : AnyObject]?, error: NSError?)
    
    // video capture progress
    
    optional func vision(vision: PBJVision, didCaptureVideoSampleBuffer sampleBuffer: CMSampleBuffer)
    optional func vision(vision: PBJVision, didCaptureAudioSample sampleBuffer: CMSampleBuffer)
}