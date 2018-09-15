//
//  SoundViewModel.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/09/15.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import Alamofire

protocol SoundViewModelDelegate: class {
}

class SoundViewModel {
    weak var delegate: SoundViewModelDelegate?
    
    let sensors = ["1", "2"]
    var currentSensor = "1"
    var isMeasuring = false
}
