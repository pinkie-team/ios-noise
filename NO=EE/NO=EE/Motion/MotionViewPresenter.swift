//
//  MotionViewPresenter.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/09/15.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

protocol ViewPresentable :class{
}

class MotionViewPresenter {
    
    weak var view: MotionViewInterface?
    let model: MotionViewModel
    
    init(view: MotionViewInterface) {
        self.view = view
        self.model = MotionViewModel()
        model.delegate = self
    }
    
    func getSensors() -> [String] {
        return model.sensors
    }
    
    func setIsMeasuring(value: Bool) {
        model.isMeasuring = value
    }
    
    func getIsMeasuring() -> Bool {
        return model.isMeasuring
    }
    
    func setDeviceMotion() {
        model.setDeviceMotion()
    }
    
    func resetValueTime() {
        model.valueTmp = ""
        model.timeTmp = ""
    }
    
    func stopDeviceMotion() {
        model.motionManager.stopDeviceMotionUpdates()
    }
    
    func writeLogFile() {
        model.writeLogFile()
    }
    
    func setCurrentSensor(value: String) {
        model.currentSensor = value
    }
    
}

extension MotionViewPresenter: MotionViewModelDelegate {
    
}
