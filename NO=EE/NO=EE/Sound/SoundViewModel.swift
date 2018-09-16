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
        audioRecorder?.stop()
        AudioQueueFlush(queue)
        AudioQueueStop(queue, false)
        AudioQueueDispose(queue, true)
        timer.invalidate()
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
        
        if levelMeter.mPeakPower >= -1.0 {
            print("+++++++++++++++ LOUD!!! +++++++++++++++")
        }
    }
}
