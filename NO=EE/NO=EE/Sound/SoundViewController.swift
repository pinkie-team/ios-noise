//
//  SoundViewController.swift
//  NO=EE
//
//  Created by 岩見建汰 on 2018/08/10.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import TinyConstraints

protocol SoundViewInterface: class {
    func updateLabel(peak: Float32, ave: Float32)
}

class SoundViewController: FormViewController {
    fileprivate var presenter: SoundViewPresenter!
    fileprivate var peakLabel: UILabel!
    fileprivate var aveLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPresenter()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "音"
    }
    
    fileprivate func initPresenter() {
        presenter = SoundViewPresenter(view: self)
    }
    
    fileprivate func initUI() {
        form +++ Section("")
            <<< PickerInputRow<String>(""){
                $0.title = "センサー種別"
                $0.options = presenter.getSensors()
                $0.value = presenter.getSensors()[0]
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
        
        peakLabel = UILabel()
        aveLabel = UILabel()
        tableView.addSubview(peakLabel)
        tableView.addSubview(aveLabel)
        peakLabel.center(in: tableView)
        aveLabel.topToBottom(of: peakLabel, offset: 10)
        aveLabel.centerX(to: tableView)
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
            presenter.setIsMeasuring(value: false)
            presenter.stopRecoding()
        }else {
            title = "計測停止"
            disabled = true
            presenter.setIsMeasuring(value: true)
            presenter.startRecoding()
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

extension SoundViewController: SoundViewInterface {
    func updateLabel(peak: Float32, ave: Float32) {
        peakLabel.text = "Peak: " + String(peak)
        aveLabel.text = "Ave: " + String(ave)
    }
}

