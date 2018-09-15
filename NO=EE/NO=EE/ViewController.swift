//
//  ViewController.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/08/10.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka

protocol ViewInterface: class {
}

class ViewController: FormViewController, ViewInterface {

    fileprivate var presenter: Presenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPresenter()
        initUI()
    }
    
    fileprivate func initPresenter() {
        presenter = Presenter(view: self)
    }
    
    fileprivate func initUI() {
        self.navigationItem.title = "Top"
        
        form +++ Section("")
            <<< PickerInputRow<String>(""){
                $0.title = "センサー種別"
                $0.options = presenter.getSensors()
                $0.value = presenter.getSensors()[0]
                $0.tag = "sensor"
                $0.cell.detailTextLabel?.textColor = UIColor.black
            }
            
            <<< PickerInputRow<String>(""){
                $0.title = "検出アルゴリズム"
                $0.options = presenter.getAlgorithms()
                $0.value = presenter.getAlgorithms()[0]
                $0.tag = "algorithm"
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
    
    func buttonTapped() {
        presenter.setCurrentSensor(value: form.values()["sensor"] as! String)
        
        let buttonRow = form.rowBy(tag: "button")
        
        if presenter.getIsMeasuring() {
            presenter.writeLogFile()
            
            presenter.resetValueTime()
            presenter.setIsMeasuring(value: false)
            
            presenter.stopDeviceMotion()
            
            buttonRow?.title = "計測開始"
            buttonRow?.updateCell()
        }else {
            presenter.setIsMeasuring(value: true)
            buttonRow?.title = "計測停止"
            buttonRow?.updateCell()
            presenter.setDeviceMotion()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

