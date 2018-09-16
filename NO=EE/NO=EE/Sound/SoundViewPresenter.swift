//
//  SoundViewPresenter.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/09/15.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

protocol SoundViewPresentable :class{
}

class SoundViewPresenter {
    
    weak var view: SoundViewInterface?
    let model: SoundViewModel
    
    init(view: SoundViewInterface) {
        self.view = view
        self.model = SoundViewModel()
        model.delegate = self
    }
    
    func getSensors() -> [String] {
        return model.sensors
    }
    
    func setCurrentSensor(value: String) {
        model.currentSensor = value
    }
    
    func setIsMeasuring(value: Bool) {
        model.isMeasuring = value
    }
    
    func getIsMeasuring() -> Bool {
        return model.isMeasuring
    }
    
    func startRecoding() {
        model.startRecoding()
    }
    
    func stopRecoding() {
        model.stopRecoding()
    }
}

extension SoundViewPresenter: SoundViewModelDelegate {
    
}
