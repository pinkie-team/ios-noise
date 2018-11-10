//
//  MotionViewController.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/08/10.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import TinyConstraints

protocol MotionViewInterface: class {
    func updateLabel(z: Double)
    func updateView(isAvailable: Bool)
}

class MotionViewController: FormViewController {

    fileprivate var presenter: MotionViewPresenter!
    fileprivate var zLabel: UILabel!
    fileprivate var availableView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPresenter()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "振動"
    }
    
    fileprivate func initPresenter() {
        presenter = MotionViewPresenter(view: self)
    }
    
    fileprivate func initUI() {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 5

        
        form +++ Section("")
            <<< PickerInputRow<String>(""){
                $0.title = "センサー種別"
                $0.options = presenter.getSensors()
                $0.value = presenter.getSensors()[0]
                $0.tag = "sensor"
                $0.cell.detailTextLabel?.textColor = UIColor.black
            }
        
            <<< DecimalRow(){
                $0.title = "閾値"
                $0.value = 0.003
                $0.formatter = formatter
                $0.tag = "threshold"
        }
        
        form +++ Section("")
            <<< ButtonRow(){
                $0.title = "計測開始"
                $0.tag = "button"
                $0.baseCell.backgroundColor = UIColor.hex(Color.orange.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
            }
            .onCellSelection {  cell, row in
                self.presenter.setThreshold(value: self.form.values()["threshold"] as! Double)
                self.buttonTapped()
        }
        
        zLabel = UILabel()
        tableView.addSubview(zLabel)
        zLabel.center(in: tableView)
        
        availableView = UIView()
        availableView.backgroundColor = UIColor.green
        tableView.addSubview(availableView)
        availableView.topToBottom(of: zLabel)
        availableView.centerX(to: tableView)
        availableView.width(self.view.frame.width/2)
        availableView.height(100)
    }
    
    fileprivate func buttonTapped() {
        presenter.setCurrentSensor(value: form.values()["sensor"] as! String)
        let sensorRow = form.rowBy(tag: "sensor")
        let buttonRow = form.rowBy(tag: "button")
        var title = ""
        var disabled: Condition = false
        
        if presenter.getIsMeasuring() {
            title = "計測開始"
            disabled = false
            presenter.writeLogFile()
            presenter.stopDeviceMotion()
            presenter.resetValueTime()
            presenter.setIsMeasuring(value: false)
        }else {
            title = "計測停止"
            disabled = true
            presenter.setIsMeasuring(value: true)
            presenter.setDeviceMotion()
        }
        
        buttonRow?.title = title
        buttonRow?.updateCell()
        
        sensorRow?.disabled = disabled
        sensorRow?.evaluateDisabled()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MotionViewController: MotionViewInterface {
    func updateLabel(z: Double) {
        zLabel.text = "z: " + String(z)
    }
    
    func updateView(isAvailable: Bool) {
        if isAvailable {
            availableView.backgroundColor = UIColor.green
        }else {
            availableView.backgroundColor = UIColor.red
        }
    }
}

