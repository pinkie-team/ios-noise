//
//  SoundViewModel.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/09/15.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import Alamofire
import AVFoundation
import AudioToolbox

protocol SoundViewModelDelegate: class {
    func updateLabel(peak: Float32, ave: Float32)
}

private func AudioQueueInputCallback(
    _ inUserData: UnsafeMutableRawPointer?,
    inAQ: AudioQueueRef,
    inBuffer: AudioQueueBufferRef,
    inStartTime: UnsafePointer<AudioTimeStamp>,
    inNumberPacketDescriptions: UInt32,
    inPacketDescs: UnsafePointer<AudioStreamPacketDescription>?){}

class SoundViewModel {
    weak var delegate: SoundViewModelDelegate?
    
    let sensors = ["1", "2"]
    var currentSensor = "1"
    var isMeasuring = false
    var audioRecorder: AVAudioRecorder?
    let fileURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/test.m4a")
    
    var queue: AudioQueueRef!
    var timer: Timer!
    var dataFormat = AudioStreamBasicDescription(
        mSampleRate: 44100.0,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: AudioFormatFlags(kLinearPCMFormatFlagIsBigEndian |
            kLinearPCMFormatFlagIsSignedInteger |
            kLinearPCMFormatFlagIsPacked),
        mBytesPerPacket: 2,
        mFramesPerPacket: 1,
        mBytesPerFrame: 2,
        mChannelsPerFrame: 1,
        mBitsPerChannel: 16,
        mReserved: 0)
    
    func startRecoding() {
        setUpRecoding()
        setUpVolume()
    }
    
    func stopRecoding() {
        timer.invalidate()
        
        AudioQueueFlush(queue)
        AudioQueueStop(queue, false)
        AudioQueueDispose(queue, true)
        audioRecorder?.stop()
    }
}



// MARK: - クロップ
extension SoundViewModel {
    fileprivate func crop() {
        let cropTime:TimeInterval = 3
        guard let recodingTime = audioRecorder?.currentTime else {
            print("Error recordedTime")
            return
        }
        
        audioRecorder?.stop()
        
        if recodingTime > cropTime {
            let croppedFileSaveURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/crop.m4a")
            
            do {
                try FileManager.default.removeItem(at: croppedFileSaveURL as URL)
                print("success remove file")
            }catch{
                print("file remove error")
            }
            
            let trimStartTime = recodingTime - cropTime
            let startTime = CMTimeMake(Int64(trimStartTime), 1)
            let endTime = CMTimeMake(Int64(recodingTime), 1)
            let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, endTime)
            
            let asset = AVAsset(url: audioRecorder!.url)
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
            exporter?.outputFileType = AVFileTypeAppleM4A
            exporter?.timeRange = exportTimeRange
            exporter?.outputURL = croppedFileSaveURL as URL
            
            exporter!.exportAsynchronously(completionHandler: {
                switch exporter!.status {
                case .completed:
                    print("Crop Success! Url -> \(croppedFileSaveURL)")
                    self.startRecoding()
                case .failed, .cancelled:
                    print("error = \(exporter?.error)")
                    self.startRecoding()
                default:
                    print("error = \(exporter?.error)")
                    self.startRecoding()
                }
            })
        }else {
            startRecoding()
            print("時間が短いのでスキップ")
        }
    }
}


// MARK: - レコーダー
extension SoundViewModel {
    fileprivate func setUpRecoding() {
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        
        let recordSetting : [String : AnyObject] = [
            AVFormatIDKey : UInt(kAudioFormatAppleLossless) as AnyObject,
            AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue as AnyObject,
            AVEncoderBitRateKey : 16 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey: 44100.0 as AnyObject
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL as URL, settings: recordSetting)
        } catch {
            fatalError("初期設定にエラー")
        }
        
        audioRecorder?.record()
    }
}

// MARK: - ボリューム
extension SoundViewModel {
    fileprivate func setUpVolume() {
        var audioQueue: AudioQueueRef? = nil
        var error = noErr
        error = AudioQueueNewInput(
            &dataFormat,
            AudioQueueInputCallback,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            .none,
            .none,
            0,
            &audioQueue)
        
        if error == noErr {
            queue = audioQueue
        }
        AudioQueueStart(queue, nil)
        
        var enabledLevelMeter: UInt32 = 1
        AudioQueueSetProperty(queue, kAudioQueueProperty_EnableLevelMetering, &enabledLevelMeter, UInt32(MemoryLayout<UInt32>.size))
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                          target: self,
                                          selector: #selector(detectVolume(_:)),
                                          userInfo: nil,
                                          repeats: true)
        timer?.fire()
    }
    
    @objc private func detectVolume(_ timer: Timer)
    {
        var levelMeter = AudioQueueLevelMeterState()
        var propertySize = UInt32(MemoryLayout<AudioQueueLevelMeterState>.size)
        
        AudioQueueGetProperty(
            queue,
            kAudioQueueProperty_CurrentLevelMeterDB,
            &levelMeter,
            &propertySize)
        
        print("mPeakPower: ", levelMeter.mPeakPower, "mAveragePower: ", levelMeter.mAveragePower)
        print("")
        
        delegate?.updateLabel(peak: levelMeter.mPeakPower, ave: levelMeter.mAveragePower)
        
        if levelMeter.mPeakPower >= -1.0 && levelMeter.mPeakPower != 0.0 && levelMeter.mAveragePower != 0.0 {
            print("+++++++++++++++ LOUD!!! +++++++++++++++")
            AudioQueueFlush(queue)
            AudioQueueStop(queue, false)
            AudioQueueDispose(queue, true)
            crop()
        }
    }
}
