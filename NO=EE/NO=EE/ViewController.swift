//
//  ViewController.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/08/10.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import CoreMotion
import Alamofire


class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    let motionManager: CMMotionManager = CMMotionManager()
    var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var valueTmp: String = ""
    var timeTmp: String = ""
    
    let sensor = 1
    let skipTime = 3
    var timer = Timer()
    var startTime:Double = 0.0
    var isCall:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionManager.deviceMotionUpdateInterval = 0.1
        
        print(motionManager.isAccelerometerActive)
        motionManager.startDeviceMotionUpdates( to:OperationQueue.current!, withHandler:{
            deviceManager, error in
            let gyro: CMRotationRate = deviceManager!.rotationRate
//            print(gyro.x)
//            print(gyro.y)
            print(gyro.z)
            let dateFormater = DateFormatter()
            dateFormater.locale = Locale(identifier: "ja_JP")
            dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let date = dateFormater.string(from: Date())
            
//            self.tmp += String(gyro.z) + " " + date + "\n"
            self.valueTmp += String(gyro.z) + ","
            self.timeTmp += date + ","
            self.appDelegate.value = self.valueTmp
            self.appDelegate.time = self.timeTmp
            self.label.text = String(format: "%.5f", gyro.z)
            
            if abs(gyro.z) > 0.003 && self.isCall {
                self.isCall = false
                self.startTime = Date().timeIntervalSince1970
                self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.CountTime), userInfo: nil, repeats: true)

                self.CallAPI(z: gyro.z)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func CallAPI(z: Double) {
        let url = "http://127.0.0.1:5000?" + "z=" + String(z) + "&sensor=" + String(sensor)
        Alamofire.request(url, method: .get).responseJSON { (response) in
            print("************** Call Done **************")
        }
    }
    
    func CountTime() {
        let elapsedTime = Date().timeIntervalSince1970 - startTime
        let flooredErapsedTime = Int(floor(elapsedTime))
        let leftTime = skipTime - flooredErapsedTime
        
        if leftTime == 0 {
            timer.invalidate()
            isCall = true
        }
    }
}

