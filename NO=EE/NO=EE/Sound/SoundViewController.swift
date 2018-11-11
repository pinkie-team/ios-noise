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
    func updateView(isAvailable: Bool)
}

class SoundViewController: FormViewController {
    fileprivate var presenter: SoundViewPresenter!
    fileprivate var peakLabel: UILabel!
    fileprivate var aveLabel: UILabel!
    fileprivate var availableView: UIView!
    
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
        
            <<< DecimalRow(){
                $0.title = "閾値"
                $0.value = 12.0
                $0.tag = "threshold"
        }
        
        <<< TextRow(){
            $0.title = "ホストIPアドレス"
            $0.value = "172.20.10.10"
            $0.add(rule: RuleRegExp(regExpr: "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}", allowsEmpty: false, msg: "形式を確認してください。ex.) 192.168.0.0"))
            $0.validationOptions = .validatesOnChange
            $0.tag = "address"
            }
            .onRowValidationChanged {cell, row in
                guard let tmp_indexPath = row.indexPath else{return}
                let rowIndex = tmp_indexPath.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, err) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = err
                            $0.cell.height = { 30 }
                            $0.cell.contentView.backgroundColor = UIColor.red
                            $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                            $0.cell.textLabel?.textAlignment = .right
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                            })
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
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
                self.presenter.setHost(address: self.form.values()["address"] as! String)
                self.buttonTapped()
        }
        
        peakLabel = UILabel()
        aveLabel = UILabel()
        tableView.addSubview(peakLabel)
        tableView.addSubview(aveLabel)
        peakLabel.center(in: tableView)
        aveLabel.topToBottom(of: peakLabel, offset: 10)
        aveLabel.centerX(to: tableView)
        
        availableView = UIView()
        availableView.backgroundColor = UIColor.green
        tableView.addSubview(availableView)
        availableView.topToBottom(of: aveLabel)
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
    
    func updateView(isAvailable: Bool) {
        if isAvailable {
            availableView.backgroundColor = UIColor.green
        }else {
            availableView.backgroundColor = UIColor.red
        }
    }
}

