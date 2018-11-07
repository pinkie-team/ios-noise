//
//  MotionViewModel.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/09/15.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import CoreMotion
import Alamofire
import SwiftyJSON

protocol MotionViewModelDelegate: class {
    func updateLabel(z: Double)
    func updateView(isAvailable: Bool)
}

class MotionViewModel {
    weak var delegate: MotionViewModelDelegate?
    var motionManager: CMMotionManager = CMMotionManager()
    
    let sensors = ["1", "2", "3"]
    var isMeasuring = false
    var valueTmp: String = ""
    var timeTmp: String = ""
    let skipTime = 3
    var timer = Timer()
    var startTime:Double = 0.0
    var isCall:Bool = true
    var currentSensor = "1"
    
    
    func setDeviceMotion() {
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 0.1
        
        print(motionManager.isAccelerometerActive)
        
        motionManager.startDeviceMotionUpdates( to:OperationQueue.current!, withHandler:{
            deviceManager, error in
            let gyro: CMRotationRate = deviceManager!.rotationRate
            print(gyro.z)
            
            self.delegate?.updateLabel(z: gyro.z)
            
            let dateFormater = DateFormatter()
            dateFormater.locale = Locale(identifier: "ja_JP")
            dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let date = dateFormater.string(from: Date())
            
            self.valueTmp += String(gyro.z) + ","
            self.timeTmp += date + ","
            
            if abs(gyro.z) > 0.003 && self.isCall {
                self.isCall = false
                self.delegate?.updateView(isAvailable: self.isCall)
                self.startTime = Date().timeIntervalSince1970
                self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.CountTime), userInfo: nil, repeats: true)
                
                self.callMotionAPI(z: gyro.z)
            }
        })
    }
    
    @objc func CountTime() {
        let elapsedTime = Date().timeIntervalSince1970 - startTime
        let flooredErapsedTime = Int(floor(elapsedTime))
        let leftTime = skipTime - flooredErapsedTime
        
        if leftTime == 0 {
            timer.invalidate()
            isCall = true
            self.delegate?.updateView(isAvailable: self.isCall)
        }
    }
}


// MARK: - Log
extension MotionViewModel {
    func writeLogFile() {
        print(currentSensor)
        let valueFileName = "value" + currentSensor + ".csv"
        let timeFileName = "time" + currentSensor + ".csv"
        
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            
            let valueTextFilePath = documentDirectoryFileURL.appendingPathComponent(valueFileName)
            let timeTextFilePath = documentDirectoryFileURL.appendingPathComponent(timeFileName)
            
            do {
                try valueTmp.write(to: valueTextFilePath, atomically: true, encoding: String.Encoding.utf8)
                try timeTmp.write(to: timeTextFilePath, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("failed to write: \(error)")
            }
        }
    }
}


// MARK: - API
extension MotionViewModel {
    func callMotionAPI(z: Double) {
        let url = "http://172.20.10.10:80/motion"
        let params = ["z": String(z), "sensor": currentSensor]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding(options: [])).validate(statusCode: 200..<600).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("***** GET Auth API Results *****")
                print(json)
                print("***** GET Auth API Results *****")
                
            case .failure(_):
                print("API Error")
            }
        }
    }
}
