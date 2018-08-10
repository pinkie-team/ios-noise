//
//  ViewController.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/08/10.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    let motionManager: CMMotionManager = CMMotionManager()
    var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var valueTmp: String = ""
    var timeTmp: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionManager.deviceMotionUpdateInterval = 0.05
        
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
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

