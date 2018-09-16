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

protocol SoundViewModelDelegate: class {
}

class SoundViewModel {
    weak var delegate: SoundViewModelDelegate?
    
    let sensors = ["1", "2"]
    var currentSensor = "1"
    var isMeasuring = false
    var audioRecorder: AVAudioRecorder?
    let fileURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/test.m4a")
    
    func startRecoding() {
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
    
    func stopRecoding() {
        audioRecorder?.stop()
    }
}
