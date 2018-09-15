//
//  Model.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/09/15.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import CoreMotion
import Alamofire

protocol ViewModelDelegate: class {
}

class Model {
    weak var delegate: ViewModelDelegate?
    var motionManager: CMMotionManager = CMMotionManager()
    
    let sensors = ["1", "2"]
    let algorithms = ["振動", "音", "両方"]
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
            
            let dateFormater = DateFormatter()
            dateFormater.locale = Locale(identifier: "ja_JP")
            dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let date = dateFormater.string(from: Date())
            
            //            self.tmp += String(gyro.z) + " " + date + "\n"
            self.valueTmp += String(gyro.z) + ","
            self.timeTmp += date + ","
            //            self.label.text = String(format: "%.5f", gyro.z)
            
            if abs(gyro.z) > 0.003 && self.isCall {
                self.isCall = false
                self.startTime = Date().timeIntervalSince1970
                self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.CountTime), userInfo: nil, repeats: true)
                
                self.callMotionAPI(z: gyro.z)
            }
        })
    }
    
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
    
    @objc func CountTime() {
        let elapsedTime = Date().timeIntervalSince1970 - startTime
        let flooredErapsedTime = Int(floor(elapsedTime))
        let leftTime = skipTime - flooredErapsedTime
        
        if leftTime == 0 {
            timer.invalidate()
            isCall = true
        }
    }

    func callMotionAPI(z: Double) {
        let url = "http://172.20.10.10:80/motion?" + "z=" + String(z) + "&sensor=" + currentSensor
        Alamofire.request(url, method: .get).responseJSON { (response) in
            print("************** Call Done **************")
        }
    }
}