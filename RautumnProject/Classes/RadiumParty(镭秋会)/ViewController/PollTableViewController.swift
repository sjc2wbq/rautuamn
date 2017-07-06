//
//  PollTableViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//发起民调

import UIKit
import Eureka
import SwiftyDrop
class PollTableViewController: FormViewController {
    let btn_done = UIButton(frame: CGRect(x: 13, y: 20, width: screenW - 26, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            title = "发起民调"
            tableView?.sectionFooterHeight = 0
            tableView?.sectionHeaderHeight = 0
            tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            DateTimeRow.defaultRowInitializer = { row in row.minimumDate = Date() }
            DateTimeRow.defaultCellUpdate = { cell , row in
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = UIColor.black
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
            }
            
            NameRow.defaultCellUpdate = { cell, row in
                cell.textField.textColor = .black
                cell.textLabel?.textColor = .black
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textField.font = UIFont.systemFont(ofSize: 15)
            }
            
            btn_done.setTitle("确定发布", for: .normal)
            btn_done.backgroundColor = UIColor.colorWithHexString("#ff8200")
            btn_done.layer.cornerRadius = 4
            btn_done.layer.masksToBounds = true
            let bottomContentView = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: 70))
            bottomContentView.backgroundColor = .clear
            bottomContentView.addSubview(btn_done)
            tableView?.tableFooterView = bottomContentView
            tableView?.backgroundColor = bgColor
            btn_done.addTarget(self, action: #selector(btn_doneAction), for: .touchUpInside)
        }
        
        do{
            
            DateTimeRow.defaultRowInitializer = { row in row.minimumDate = Date() }
            
            form +++
                
                Section()
                
                <<< TextRow() {
                    $0.title = "民调标题"
                    $0.placeholder = "请输入标题，15字以内(某个社会热点问题)"
                    $0.tag = "section1Row1"
                }
                
                
                <<< TextRow() {
                    $0.title = "选项A(正面)"
                    $0.placeholder = "请输入"
                    $0.tag = "section1Row2"
                }
                
                
                
                <<< TextRow() {
                    $0.title = "选项B(负面)"
                    $0.placeholder = "请输入"
                    $0.tag = "section1Row3"
                }
                
                
                
                <<< TextRow() {
                    $0.title = "选项C(中性)"
                    $0.value = "默认为打酱油"
                    $0.placeholder = "默认为打酱油"
                    $0.tag = "section1Row4"
                    $0.disabled = true
                }
                
                +++  Section()
                <<< DateTimeRow() {
                    $0.title = "投票截止时间"
                    $0.value = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.locale = .current
                    formatter.dateStyle = .long
                    formatter.timeStyle = .short
                    $0.dateFormatter = formatter
                    $0.baseCell.accessoryView = self.accessView("arrowDownIcon")
                    $0.tag = "section2Row1"
                    
            }
        }

    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    @objc fileprivate func btn_doneAction(){
        self.view.endEditing(true)
        let section1Row1 =  self.form.rowBy(tag: "section1Row1") as? TextRow
        let section1Row2 =  self.form.rowBy(tag: "section1Row2") as? TextRow
        let section1Row3 =  self.form.rowBy(tag: "section1Row3") as? TextRow
        let section1Row4 =  self.form.rowBy(tag: "section1Row4") as? TextRow
        let section2Row1 =  self.form.rowBy(tag: "section2Row1") as? DateTimeRow
        
        
        guard let section1Row1Value = section1Row1?.value else {
            Drop.down("请输入标题，15字以内！", state: .error)
            return
        }
        if (section1Row1Value.characters.count > 15){
            Drop.down("请输入标题，15字以内！", state: .error)
            return
        }
        
        
        guard let section1Row2Value = section1Row2?.value else {
            Drop.down("请输入选项A的内容！", state: .error)
            return
        }
        if section1Row2Value.characters.count == 0{
            Drop.down("请输入选项A的内容！", state: .error)
            return
        }
        
        guard let section1Row3Value = section1Row3?.value else {
            Drop.down("请输入选项B的内容！", state: .error)
            return
        }
        
        if section1Row3Value.characters.count == 0{
            Drop.down("请输入选项B的内容！", state: .error)
            return
        }
        
        guard let section1Row4Value = section1Row4?.value else {
            Drop.down("请输入选项C的内容！", state: .error)
            return
        }
        
        if section1Row4Value.characters.count == 0{
            Drop.down("请输入选项C的内容！", state: .error)
            return
        }
        var param = PublishRFCMParam()
        param.title = section1Row1Value
        param.optionA = section1Row2Value
        param.optionB = section1Row3Value
        param.optionC = section1Row4Value
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        param.endEffectiveDate = formatter.string(from: section2Row1!.value!)
        
        let activityIndicator = ActivityIndicator()
        
        activityIndicator.asObservable()
            .map{!$0}.bindTo(self.btn_done.rx.isEnabled).addDisposableTo(rx_disposeBag)
        
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "", for: view)).addDisposableTo(rx_disposeBag)
        let request =  RequestProvider.request(api: ParametersAPI.publishRFCM(param: param)).mapObject(type: Raufricivilmediation.self)
            .trackActivity(activityIndicator)
            .shareReplay(1)
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: { (model) in
                Drop.down("发布成功！", state: .success)
                _  =  self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "publishRFCMSuccessNotifation"), object: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
    
    fileprivate func accessView(_ imageNamed:String) -> UIImageView{
        let imageView = UIImageView()
        imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        imageView.contentMode = .center
        imageView.image = UIImage(named: imageNamed)
        imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        return imageView
    }

}
