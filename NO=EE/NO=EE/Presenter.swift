//
//  Presenter.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/09/15.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

protocol ViewPresentable :class{
    var shiftCategories: [String] { get }
    var eventNumber: Int { get }
    var userColorScheme: String { get }
}

class Presenter {
    
    weak var view: ViewInterface?
    let model: Model
    
    init(view: ViewInterface) {
        self.view = view
        self.model = Model()
        model.delegate = self
    }
    
    func getSensors() -> [String] {
        return model.sensors
    }
    
    func getAlgorithms() -> [String] {
        return model.algorithms
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

extension Presenter: ViewModelDelegate {
    
}
