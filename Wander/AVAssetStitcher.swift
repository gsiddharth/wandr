//
//  AVAssetStitcher.swift
//  Wander
//
//  Created by Siddharth Garg on 29/03/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import UIKit
import AVFoundation

class AVAssetStitcher {
    
    var outputSize : CGSize!
    var composition : AVMutableComposition!
    var compositionVideoTrack : AVMutableCompositionTrack!
    var compositionAudioTrack : AVMutableCompositionTrack!
    
    var instructions = [AVMutableVideoCompositionInstruction]()
    
    
    init(outSize: CGSize){
        self.outputSize = outSize
        self.composition = AVMutableComposition()
        self.compositionVideoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo,preferredTrackID:Int32(kCMPersistentTrackID_Invalid))
        
        self.compositionAudioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio,preferredTrackID:Int32(kCMPersistentTrackID_Invalid))
    }
    
    func addAsset(asset : AVURLAsset, withTransform transformToApply: ((AVAssetTrack) -> CGAffineTransform)!, withErrorHandler errorHandler : ((NSErrorPointer) -> Void)!){
        
        var videoTrack : AVAssetTrack = (asset.tracksWithMediaType(AVMediaTypeVideo)).first as AVAssetTrack
        var instruction = AVMutableVideoCompositionInstruction()
        var layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        if transformToApply != nil {
            layerInstruction.setTransform(CGAffineTransformConcat(videoTrack.preferredTransform, transformToApply(videoTrack)), atTime: kCMTimeZero)
        } else {
            layerInstruction.setTransform(videoTrack.preferredTransform, atTime: kCMTimeZero)
        }
        
        instruction.layerInstructions = [layerInstruction]
    
        var startTime : CMTime = kCMTimeZero
        
        for instr in instructions {
            startTime = CMTimeAdd(startTime, instr.timeRange.duration)
        }
        
        instruction.timeRange = CMTimeRangeMake(startTime, asset.duration)
        instructions.append(instruction)
        
        var error : NSErrorPointer = NSErrorPointer()
        
        compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: videoTrack, atTime: kCMTimeZero, error: error)
        
        if error != nil {
            errorHandler(error)
            return
        }
        
        var audioTrack : AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeAudio).first as AVAssetTrack
       
        compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: audioTrack, atTime: kCMTimeZero, error: error)
        
        if error != nil {
            errorHandler(error)
            return
        }
        
    }
    
    func exportTo(outputFile: NSURL, withPreset preset : String, withCompletionHandler completionHandler: ((NSError!) -> Void)!){
        
        var videoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.instructions = self.instructions
        videoComposition.renderSize = outputSize
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        var exporter : AVAssetExportSession = AVAssetExportSession(asset : self.composition, presetName : preset)
    
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.videoComposition = videoComposition
        exporter.outputURL = outputFile
        
        exporter.exportAsynchronouslyWithCompletionHandler({ () -> Void in
            
            if exporter.status == AVAssetExportSessionStatus.Failed {
                completionHandler(exporter.error)
            } else if exporter.status == AVAssetExportSessionStatus.Cancelled || exporter.status == AVAssetExportSessionStatus.Completed{
                completionHandler(nil)
            } else {
                completionHandler(NSError(domain: "Unknown export error", code: 100, userInfo: nil))
            }
        })
        
    }
}