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
import Eureka

class ViewController: FormViewController {

    var motionManager: CMMotionManager = CMMotionManager()
    var valueTmp: String = ""
    var timeTmp: String = ""
    
    let skipTime = 3
    var timer = Timer()
    var startTime:Double = 0.0
    var isCall:Bool = true
    var isMeasure: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    func CallAPI(z: Double) {
        let sensor = form.values()["sensor"] as! String
        let url = "http://127.0.0.1:5000?" + "z=" + String(z) + "&sensor=" + sensor
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
    
    func initUI() {
        self.navigationItem.title = "Top"
        
        form +++ Section("")
            <<< PickerInputRow<String>(""){
                $0.title = "センサー種別"
                $0.options = getSensors()
                $0.value = getSensors()[0]
                $0.tag = "sensor"
                $0.cell.detailTextLabel?.textColor = UIColor.black
            }
        
        form +++ Section("")
            <<< ButtonRow(){
                $0.title = "計測開始"
                $0.tag = "button"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
            }
            .onCellSelection {  cell, row in
                self.buttonTapped()
            }
    }
    
    func getSensors() -> [String] {
        return ["1", "2"]
    }
    
    func buttonTapped() {
        let buttonRow = form.rowBy(tag: "button")
        
        if isMeasure {
            writeLogFile()
            
            valueTmp = ""
            timeTmp = ""
            isMeasure = false
            
            motionManager.stopDeviceMotionUpdates()
            
            buttonRow?.title = "計測開始"
            buttonRow?.updateCell()
        }else {
            isMeasure = true
            buttonRow?.title = "計測停止"
            buttonRow?.updateCell()
            deviceMotion()
        }
    }
    
    func deviceMotion() {
        motionManager = CMMotionManager()
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
//            self.label.text = String(format: "%.5f", gyro.z)

            if abs(gyro.z) > 0.003 && self.isCall {
                self.isCall = false
                self.startTime = Date().timeIntervalSince1970
                self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.CountTime), userInfo: nil, repeats: true)

                self.CallAPI(z: gyro.z)
            }
        })
    }
    
    func writeLogFile() {
        let sensor = form.values()["sensor"] as! String
        let valueFileName = "value" + sensor + ".csv"
        let timeFileName = "time" + sensor + ".csv"
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

