//
//  MotionViewPresenter.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/09/15.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

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
    
    func setThreshold(value: Double) {
        model.threshold = value
    }
    
    func setHost(address: String) {
        model.host = address
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
    func updateLabel(z: Double) {
        view?.updateLabel(z: z)
    }
    
    func updateView(isAvailable: Bool) {
        view?.updateView(isAvailable: isAvailable)
    }
}
